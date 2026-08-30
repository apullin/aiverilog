/*
 * Copyright (c) 2026 Andrew Pullin
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Experimental clock-edge waveform recorder for Icarus Verilog.
 */

#include <sv_vpi_user.h>
#include <lz4.h>

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define WTRACE_VERSION 1
#define WTRACE_NO_SCOPE UINT32_MAX
#define WTRACE_CLOCK_FLAG 0x01
#define WTRACE_BLOCK_SIZE (64 * 1024)
#define WTRACE_RAW_BLOCK_FLAG UINT32_C(0x80000000)

enum wtrace_state {
      WTRACE_IDLE,
      WTRACE_ACTIVE,
      WTRACE_CLOSED,
      WTRACE_FAILED
};

enum wtrace_scope_kind {
      WTRACE_SCOPE_MODULE,
      WTRACE_SCOPE_GENERATE,
      WTRACE_SCOPE_FUNCTION,
      WTRACE_SCOPE_TASK,
      WTRACE_SCOPE_BEGIN,
      WTRACE_SCOPE_FORK
};

enum wtrace_signal_kind {
      WTRACE_SIGNAL_WIRE,
      WTRACE_SIGNAL_REG,
      WTRACE_SIGNAL_INTEGER,
      WTRACE_SIGNAL_TIME,
      WTRACE_SIGNAL_BIT,
      WTRACE_SIGNAL_BYTE,
      WTRACE_SIGNAL_SHORTINT,
      WTRACE_SIGNAL_INT,
      WTRACE_SIGNAL_LONGINT,
      WTRACE_SIGNAL_MEMORY_WORD
};

struct wtrace_scope {
      char *name;
      char *full_name;
      uint32_t parent;
      uint8_t kind;
      int scanned;
};

struct wtrace_signal {
      vpiHandle object;
      vpiHandle callback;
      s_vpi_time callback_time;
      char *name;
      char *full_name;
      uint32_t scope_id;
      uint32_t width;
      int32_t left;
      int32_t right;
      uint8_t kind;
      uint8_t flags;
      size_t id;
      uint32_t *last_aval;
      uint32_t *last_bval;
      uint32_t *next_aval;
      uint32_t *next_bval;
      size_t word_count;
      size_t plane_size;
      int dirty;
      int emit;
      int four_state;
};

struct wtrace_context {
      enum wtrace_state state;
      char *path;
      FILE *file;
      uint8_t *block;
      uint8_t *compressed_block;
      size_t block_used;
      size_t compressed_capacity;

      struct wtrace_scope *scopes;
      size_t scope_count;
      size_t scope_capacity;

      struct wtrace_signal *signals;
      size_t signal_count;
      size_t signal_capacity;
      size_t *signal_hash;
      size_t signal_hash_capacity;
      size_t *dirty_ids;
      size_t dirty_count;

      vpiHandle clock;
      vpiHandle clock_callback;
      s_vpi_time clock_time;
      s_vpi_time sample_time;
      int sample_pending;

      uint64_t last_frame_time;
      uint64_t frame_count;
      uint64_t value_count;
      uint64_t value_bytes;
      int have_frame;
};

static struct wtrace_context trace;

static void wtrace_fail(const char *message)
{
      if (trace.state == WTRACE_FAILED) return;
      trace.state = WTRACE_FAILED;
      vpi_printf("WTRACE error: %s\n", message);
}

static char *wtrace_strdup(const char *text)
{
      size_t length;
      char *copy;

      if (!text) text = "";
      length = strlen(text) + 1;
      copy = (char *)malloc(length);
      if (!copy) {
            wtrace_fail("out of memory");
            return 0;
      }
      memcpy(copy, text, length);
      return copy;
}

static int reserve_scopes(size_t count)
{
      struct wtrace_scope *next;
      size_t capacity = trace.scope_capacity ? trace.scope_capacity : 16;

      if (count <= trace.scope_capacity) return 1;
      while (capacity < count) capacity *= 2;
      next = (struct wtrace_scope *)realloc(trace.scopes,
                                             capacity * sizeof(*next));
      if (!next) {
            wtrace_fail("out of memory while collecting scopes");
            return 0;
      }
      trace.scopes = next;
      trace.scope_capacity = capacity;
      return 1;
}

static int reserve_signals(size_t count)
{
      struct wtrace_signal *next;
      size_t capacity = trace.signal_capacity ? trace.signal_capacity : 64;

      if (count <= trace.signal_capacity) return 1;
      while (capacity < count) capacity *= 2;
      next = (struct wtrace_signal *)realloc(trace.signals,
                                               capacity * sizeof(*next));
      if (!next) {
            wtrace_fail("out of memory while collecting signals");
            return 0;
      }
      trace.signals = next;
      trace.signal_capacity = capacity;
      return 1;
}

static uint64_t hash_name(const char *name)
{
      uint64_t hash = UINT64_C(1469598103934665603);
      const unsigned char *cursor = (const unsigned char *)name;

      while (*cursor) {
            hash ^= *cursor++;
            hash *= UINT64_C(1099511628211);
      }
      return hash;
}

static int rebuild_signal_hash(size_t capacity)
{
      size_t *slots;
      size_t idx;

      slots = (size_t *)calloc(capacity, sizeof(*slots));
      if (!slots) {
            wtrace_fail("out of memory while indexing signals");
            return 0;
      }

      for (idx = 0; idx < trace.signal_count; idx += 1) {
            size_t slot = (size_t)hash_name(trace.signals[idx].full_name)
                        & (capacity - 1);
            while (slots[slot]) slot = (slot + 1) & (capacity - 1);
            slots[slot] = idx + 1;
      }

      free(trace.signal_hash);
      trace.signal_hash = slots;
      trace.signal_hash_capacity = capacity;
      return 1;
}

static int ensure_signal_hash(void)
{
      size_t capacity = trace.signal_hash_capacity;

      if (!capacity) return rebuild_signal_hash(128);
      if ((trace.signal_count + 1) * 10 < capacity * 7) return 1;
      return rebuild_signal_hash(capacity * 2);
}

static size_t find_signal(const char *full_name)
{
      size_t slot;

      if (!trace.signal_hash_capacity) return SIZE_MAX;
      slot = (size_t)hash_name(full_name) & (trace.signal_hash_capacity - 1);
      while (trace.signal_hash[slot]) {
            size_t idx = trace.signal_hash[slot] - 1;
            if (strcmp(trace.signals[idx].full_name, full_name) == 0)
                  return idx;
            slot = (slot + 1) & (trace.signal_hash_capacity - 1);
      }
      return SIZE_MAX;
}

static int index_signal(size_t idx)
{
      size_t previous_capacity = trace.signal_hash_capacity;
      size_t slot;

      if (!ensure_signal_hash()) return 0;
      /* A rebuild indexed every current signal, including this one. */
      if (trace.signal_hash_capacity != previous_capacity) return 1;
      slot = (size_t)hash_name(trace.signals[idx].full_name)
           & (trace.signal_hash_capacity - 1);
      while (trace.signal_hash[slot])
            slot = (slot + 1) & (trace.signal_hash_capacity - 1);
      trace.signal_hash[slot] = idx + 1;
      return 1;
}

static int is_scope_type(PLI_INT32 type)
{
      switch (type) {
          case vpiModule:
          case vpiGenScope:
          case vpiFunction:
          case vpiTask:
          case vpiNamedBegin:
          case vpiNamedFork:
            return 1;
          default:
            return 0;
      }
}

static uint8_t scope_kind(PLI_INT32 type)
{
      switch (type) {
          case vpiGenScope:   return WTRACE_SCOPE_GENERATE;
          case vpiFunction:   return WTRACE_SCOPE_FUNCTION;
          case vpiTask:       return WTRACE_SCOPE_TASK;
          case vpiNamedBegin: return WTRACE_SCOPE_BEGIN;
          case vpiNamedFork:  return WTRACE_SCOPE_FORK;
          default:            return WTRACE_SCOPE_MODULE;
      }
}

static uint32_t find_scope(const char *full_name)
{
      size_t idx;
      for (idx = 0; idx < trace.scope_count; idx += 1) {
            if (strcmp(trace.scopes[idx].full_name, full_name) == 0)
                  return (uint32_t)idx;
      }
      return WTRACE_NO_SCOPE;
}

static uint32_t ensure_scope(vpiHandle object)
{
      char *full_name;
      char *name;
      vpiHandle parent_object;
      uint32_t found;
      uint32_t parent = WTRACE_NO_SCOPE;
      size_t idx;

      if (!object || !is_scope_type(vpi_get(vpiType, object)))
            return WTRACE_NO_SCOPE;

      full_name = wtrace_strdup(vpi_get_str(vpiFullName, object));
      if (!full_name) return WTRACE_NO_SCOPE;
      found = find_scope(full_name);
      if (found != WTRACE_NO_SCOPE) {
            free(full_name);
            return found;
      }

      name = wtrace_strdup(vpi_get_str(vpiName, object));
      if (!name) {
            free(full_name);
            return WTRACE_NO_SCOPE;
      }

      parent_object = vpi_handle(vpiScope, object);
      if (parent_object && is_scope_type(vpi_get(vpiType, parent_object)))
            parent = ensure_scope(parent_object);

      if (!reserve_scopes(trace.scope_count + 1)) {
            free(name);
            free(full_name);
            return WTRACE_NO_SCOPE;
      }

      idx = trace.scope_count++;
      trace.scopes[idx].name = name;
      trace.scopes[idx].full_name = full_name;
      trace.scopes[idx].parent = parent;
      trace.scopes[idx].kind = scope_kind(vpi_get(vpiType, object));
      trace.scopes[idx].scanned = 0;
      return (uint32_t)idx;
}

static int signal_kind(PLI_INT32 type, uint8_t *kind)
{
      switch (type) {
          case vpiNet:         *kind = WTRACE_SIGNAL_WIRE; return 1;
          case vpiReg:         *kind = WTRACE_SIGNAL_REG; return 1;
          case vpiIntegerVar:  *kind = WTRACE_SIGNAL_INTEGER; return 1;
          case vpiTimeVar:     *kind = WTRACE_SIGNAL_TIME; return 1;
          case vpiBitVar:      *kind = WTRACE_SIGNAL_BIT; return 1;
          case vpiByteVar:     *kind = WTRACE_SIGNAL_BYTE; return 1;
          case vpiShortIntVar: *kind = WTRACE_SIGNAL_SHORTINT; return 1;
          case vpiIntVar:      *kind = WTRACE_SIGNAL_INT; return 1;
          case vpiLongIntVar:  *kind = WTRACE_SIGNAL_LONGINT; return 1;
          case vpiMemoryWord:  *kind = WTRACE_SIGNAL_MEMORY_WORD; return 1;
          default: return 0;
      }
}

static size_t add_signal(vpiHandle object, uint32_t fallback_scope)
{
      struct wtrace_signal *signal;
      char *full_name;
      char *name;
      uint8_t kind;
      PLI_INT32 width;
      uint32_t scope_id = fallback_scope;
      size_t existing;
      size_t idx;
      vpiHandle object_scope;

      if (!object || !signal_kind(vpi_get(vpiType, object), &kind))
            return SIZE_MAX;
      if (vpi_get(vpiAutomatic, object)) return SIZE_MAX;

      full_name = wtrace_strdup(vpi_get_str(vpiFullName, object));
      if (!full_name) return SIZE_MAX;
      existing = find_signal(full_name);
      if (existing != SIZE_MAX) {
            free(full_name);
            return existing;
      }

      width = vpi_get(vpiSize, object);
      if (width <= 0) {
            free(full_name);
            return SIZE_MAX;
      }

      name = wtrace_strdup(vpi_get_str(vpiName, object));
      if (!name) {
            free(full_name);
            return SIZE_MAX;
      }

      object_scope = vpi_handle(vpiScope, object);
      if (object_scope) {
            uint32_t actual_scope = ensure_scope(object_scope);
            if (actual_scope != WTRACE_NO_SCOPE) scope_id = actual_scope;
      }
      if (scope_id == WTRACE_NO_SCOPE) {
            free(name);
            free(full_name);
            return SIZE_MAX;
      }

      if (!reserve_signals(trace.signal_count + 1)) {
            free(name);
            free(full_name);
            return SIZE_MAX;
      }

      idx = trace.signal_count++;
      signal = &trace.signals[idx];
      memset(signal, 0, sizeof(*signal));
      signal->object = object;
      signal->name = name;
      signal->full_name = full_name;
      signal->scope_id = scope_id;
      signal->width = (uint32_t)width;
      signal->left = vpi_get(vpiLeftRange, object);
      signal->right = vpi_get(vpiRightRange, object);
      signal->kind = kind;
      signal->word_count = ((size_t)signal->width + 31) / 32;
      signal->plane_size = ((size_t)signal->width + 7) / 8;

      if (!index_signal(idx)) return SIZE_MAX;
      return idx;
}

static void scan_signal_relation(vpiHandle scope, uint32_t scope_id,
                                 PLI_INT32 relation)
{
      vpiHandle iterator = vpi_iterate(relation, scope);
      vpiHandle object;
      while (iterator && (object = vpi_scan(iterator)))
            add_signal(object, scope_id);
}

static void scan_memories(vpiHandle scope, uint32_t scope_id)
{
      vpiHandle memories = vpi_iterate(vpiMemory, scope);
      vpiHandle memory;

      while (memories && (memory = vpi_scan(memories))) {
            vpiHandle words = vpi_iterate(vpiMemoryWord, memory);
            vpiHandle word;
            while (words && (word = vpi_scan(words)))
                  add_signal(word, scope_id);
      }
}

static void scan_scope(vpiHandle scope)
{
      static const PLI_INT32 child_relations[] = {
            vpiModule, vpiGenScope, vpiFunction, vpiTask,
            vpiNamedBegin, vpiNamedFork
      };
      uint32_t scope_id = ensure_scope(scope);
      size_t relation;

      if (scope_id == WTRACE_NO_SCOPE || trace.state == WTRACE_FAILED) return;
      if (trace.scopes[scope_id].scanned) return;
      trace.scopes[scope_id].scanned = 1;

      scan_signal_relation(scope, scope_id, vpiNet);
      scan_signal_relation(scope, scope_id, vpiReg);
      scan_signal_relation(scope, scope_id, vpiVariables);
      scan_memories(scope, scope_id);

      for (relation = 0;
           relation < sizeof(child_relations) / sizeof(child_relations[0]);
           relation += 1) {
            vpiHandle iterator = vpi_iterate(child_relations[relation], scope);
            vpiHandle child;
            while (iterator && (child = vpi_scan(iterator)))
                  scan_scope(child);
      }
}

static int compare_signals(const void *left, const void *right)
{
      const struct wtrace_signal *a = (const struct wtrace_signal *)left;
      const struct wtrace_signal *b = (const struct wtrace_signal *)right;
      return strcmp(a->full_name, b->full_name);
}

static int compare_signal_ids(const void *left, const void *right)
{
      size_t a = *(const size_t *)left;
      size_t b = *(const size_t *)right;
      return (a > b) - (a < b);
}

static int file_write(const void *data, size_t length)
{
      if (fwrite(data, 1, length, trace.file) != length) {
            wtrace_fail("failed to write trace");
            return 0;
      }
      return 1;
}

static int file_write_u32(uint32_t value)
{
      uint8_t bytes[4];
      bytes[0] = (uint8_t)value;
      bytes[1] = (uint8_t)(value >> 8);
      bytes[2] = (uint8_t)(value >> 16);
      bytes[3] = (uint8_t)(value >> 24);
      return file_write(bytes, sizeof(bytes));
}

static int flush_block(void)
{
      int compressed_size;
      uint32_t stored_size;

      if (!trace.block_used) return 1;
      compressed_size = LZ4_compress_default(
            (const char *)trace.block, (char *)trace.compressed_block,
            (int)trace.block_used, (int)trace.compressed_capacity);
      if (compressed_size <= 0) {
            wtrace_fail("LZ4 could not compress a trace block");
            return 0;
      }

      if ((size_t)compressed_size >= trace.block_used) {
            stored_size = (uint32_t)trace.block_used | WTRACE_RAW_BLOCK_FLAG;
            if (!file_write_u32(stored_size) ||
                !file_write_u32((uint32_t)trace.block_used) ||
                !file_write(trace.block, trace.block_used)) return 0;
      } else {
            if (!file_write_u32((uint32_t)compressed_size) ||
                !file_write_u32((uint32_t)trace.block_used) ||
                !file_write(trace.compressed_block,
                            (size_t)compressed_size)) return 0;
      }
      trace.block_used = 0;
      return 1;
}

static int write_bytes(const void *data, size_t length)
{
      const uint8_t *cursor = (const uint8_t *)data;
      while (length) {
            size_t available = WTRACE_BLOCK_SIZE - trace.block_used;
            size_t chunk = length < available ? length : available;
            memcpy(trace.block + trace.block_used, cursor, chunk);
            trace.block_used += chunk;
            cursor += chunk;
            length -= chunk;
            if (trace.block_used == WTRACE_BLOCK_SIZE && !flush_block()) return 0;
      }
      return 1;
}

static int write_u8(uint8_t value)
{
      return write_bytes(&value, 1);
}

static int write_uvarint(uint64_t value)
{
      uint8_t bytes[10];
      size_t count = 0;
      do {
            uint8_t byte = (uint8_t)(value & 0x7f);
            value >>= 7;
            if (value) byte |= 0x80;
            bytes[count++] = byte;
      } while (value);
      return write_bytes(bytes, count);
}

static int write_svarint(int32_t value)
{
      uint64_t encoded;
      if (value < 0)
            encoded = (uint64_t)(-(int64_t)value) * 2 - 1;
      else
            encoded = (uint64_t)value * 2;
      return write_uvarint(encoded);
}

static int write_string(const char *value)
{
      size_t length = strlen(value);
      return write_uvarint(length) && write_bytes(value, length);
}

static int write_metadata(void)
{
      size_t idx;

      if (!write_uvarint(trace.scope_count)) return 0;
      for (idx = 0; idx < trace.scope_count; idx += 1) {
            const struct wtrace_scope *scope = &trace.scopes[idx];
            uint64_t parent = scope->parent == WTRACE_NO_SCOPE
                            ? 0 : (uint64_t)scope->parent + 1;
            if (!write_uvarint(parent) ||
                !write_u8(scope->kind) ||
                !write_string(scope->name)) return 0;
      }

      if (!write_uvarint(trace.signal_count)) return 0;
      for (idx = 0; idx < trace.signal_count; idx += 1) {
            const struct wtrace_signal *signal = &trace.signals[idx];
            if (!write_uvarint(signal->scope_id) ||
                !write_u8(signal->kind) ||
                !write_u8(signal->flags) ||
                !write_uvarint(signal->width) ||
                !write_svarint(signal->left) ||
                !write_svarint(signal->right) ||
                !write_string(signal->name)) return 0;
      }
      return 1;
}

static uint64_t time_to_uint64(const s_vpi_time *time)
{
      return ((uint64_t)time->high << 32) | (uint64_t)time->low;
}

static uint8_t vector_bit(const uint32_t *plane, uint32_t bit)
{
      return (uint8_t)((plane[bit / 32] >> (bit % 32)) & 1);
}

static void sample_value(struct wtrace_signal *signal)
{
      s_vpi_value value;
      size_t word;
      unsigned final_bits;
      uint32_t final_mask;

      value.format = vpiVectorVal;
      vpi_get_value(signal->object, &value);
      signal->four_state = 0;
      for (word = 0; word < signal->word_count; word += 1) {
            signal->next_aval[word] = (uint32_t)value.value.vector[word].aval;
            signal->next_bval[word] = (uint32_t)value.value.vector[word].bval;
            if (signal->next_bval[word]) signal->four_state = 1;
      }

      final_bits = signal->width % 32;
      if (!final_bits) return;
      final_mask = (UINT32_C(1) << final_bits) - 1;
      signal->next_aval[signal->word_count - 1] &= final_mask;
      signal->next_bval[signal->word_count - 1] &= final_mask;
}

static int write_binary_value(const uint32_t *plane, size_t bytes)
{
      uint8_t buffer[256];
      size_t byte = 0;

      while (byte < bytes) {
            size_t chunk = bytes - byte;
            size_t offset;
            if (chunk > sizeof(buffer)) chunk = sizeof(buffer);
            for (offset = 0; offset < chunk; offset += 1) {
                  size_t source_byte = byte + offset;
                  buffer[offset] = (uint8_t)(
                        plane[source_byte / 4] >> (8 * (source_byte % 4)));
            }
            if (!write_bytes(buffer, chunk)) return 0;
            byte += chunk;
      }
      return 1;
}

static int write_four_state_value(const struct wtrace_signal *signal)
{
      uint8_t buffer[256];
      uint32_t bit = 0;

      while (bit < signal->width) {
            uint32_t chunk_bits = signal->width - bit;
            uint32_t chunk_bytes;
            uint32_t offset;
            if (chunk_bits > sizeof(buffer) * 4) chunk_bits = sizeof(buffer) * 4;
            chunk_bytes = (chunk_bits + 3) / 4;
            memset(buffer, 0, chunk_bytes);
            for (offset = 0; offset < chunk_bits; offset += 1) {
                  uint32_t source_bit = bit + offset;
                  uint8_t aval = vector_bit(signal->next_aval, source_bit);
                  uint8_t bval = vector_bit(signal->next_bval, source_bit);
                  uint8_t encoded = bval ? (aval ? 2 : 3) : aval;
                  buffer[offset / 4] |= encoded << (2 * (offset % 4));
            }
            if (!write_bytes(buffer, chunk_bytes)) return 0;
            bit += chunk_bits;
      }
      return 1;
}

static PLI_INT32 sample_callback(p_cb_data cause)
{
      uint64_t now;
      uint64_t delta;
      uint64_t changed = 0;
      size_t dirty_idx;
      size_t previous = 0;
      int first = 1;

      trace.sample_pending = 0;
      if (trace.state != WTRACE_ACTIVE) return 0;

      now = time_to_uint64(cause->time);
      if (trace.have_frame && now < trace.last_frame_time) {
            wtrace_fail("simulation time moved backwards");
            return 0;
      }

      qsort(trace.dirty_ids, trace.dirty_count, sizeof(*trace.dirty_ids),
            compare_signal_ids);
      for (dirty_idx = 0; dirty_idx < trace.dirty_count; dirty_idx += 1) {
            size_t idx = trace.dirty_ids[dirty_idx];
            struct wtrace_signal *signal = &trace.signals[idx];
            signal->emit = 0;
            sample_value(signal);
            signal->dirty = 0;
            if (!trace.have_frame ||
                memcmp(signal->last_aval, signal->next_aval,
                       signal->word_count * sizeof(*signal->last_aval)) != 0 ||
                memcmp(signal->last_bval, signal->next_bval,
                       signal->word_count * sizeof(*signal->last_bval)) != 0) {
                  signal->emit = 1;
                  changed += 1;
            }
      }

      delta = trace.have_frame ? now - trace.last_frame_time : now;
      if (!write_u8(1) || !write_uvarint(delta) || !write_uvarint(changed))
            return 0;

      for (dirty_idx = 0; dirty_idx < trace.dirty_count; dirty_idx += 1) {
            size_t idx = trace.dirty_ids[dirty_idx];
            struct wtrace_signal *signal = &trace.signals[idx];
            uint64_t id_delta;
            uint64_t encoded_id;
            size_t encoded_size;
            if (!signal->emit) continue;
            id_delta = first ? idx : idx - previous;
            encoded_id = ((uint64_t)id_delta << 1)
                       | (signal->four_state ? 1 : 0);
            if (!write_uvarint(encoded_id)) return 0;
            if (signal->four_state) {
                  if (!write_four_state_value(signal)) return 0;
                  encoded_size = ((size_t)signal->width + 3) / 4;
            } else {
                  if (!write_binary_value(signal->next_aval,
                                          signal->plane_size)) return 0;
                  encoded_size = signal->plane_size;
            }
            memcpy(signal->last_aval, signal->next_aval,
                   signal->word_count * sizeof(*signal->last_aval));
            memcpy(signal->last_bval, signal->next_bval,
                   signal->word_count * sizeof(*signal->last_bval));
            previous = idx;
            first = 0;
            trace.value_count += 1;
            trace.value_bytes += encoded_size;
      }

      trace.have_frame = 1;
      trace.last_frame_time = now;
      trace.frame_count += 1;
      trace.dirty_count = 0;
      return 0;
}

static void schedule_sample(void)
{
      s_cb_data callback;

      if (trace.state != WTRACE_ACTIVE || trace.sample_pending) return;
      memset(&callback, 0, sizeof(callback));
      memset(&trace.sample_time, 0, sizeof(trace.sample_time));
      trace.sample_time.type = vpiSimTime;
      callback.reason = cbReadOnlySynch;
      callback.cb_rtn = sample_callback;
      callback.time = &trace.sample_time;
      if (!vpi_register_cb(&callback)) {
            wtrace_fail("could not register a sampling callback");
            return;
      }
      trace.sample_pending = 1;
}

static PLI_INT32 dirty_callback(p_cb_data cause)
{
      struct wtrace_signal *signal = (struct wtrace_signal *)cause->user_data;
      if (trace.state == WTRACE_ACTIVE && !signal->dirty) {
            signal->dirty = 1;
            trace.dirty_ids[trace.dirty_count++] = signal->id;
      }
      return 0;
}

static PLI_INT32 clock_callback(p_cb_data cause)
{
      (void)cause;
      schedule_sample();
      return 0;
}

static void release_trace_data(void)
{
      size_t idx;
      for (idx = 0; idx < trace.signal_count; idx += 1) {
            free(trace.signals[idx].name);
            free(trace.signals[idx].full_name);
            free(trace.signals[idx].last_aval);
            free(trace.signals[idx].last_bval);
            free(trace.signals[idx].next_aval);
            free(trace.signals[idx].next_bval);
      }
      for (idx = 0; idx < trace.scope_count; idx += 1) {
            free(trace.scopes[idx].name);
            free(trace.scopes[idx].full_name);
      }
      free(trace.signals);
      free(trace.scopes);
      free(trace.signal_hash);
      free(trace.dirty_ids);
      free(trace.block);
      free(trace.compressed_block);
      trace.signals = 0;
      trace.scopes = 0;
      trace.signal_hash = 0;
      trace.dirty_ids = 0;
      trace.block = 0;
      trace.compressed_block = 0;
      trace.signal_count = 0;
      trace.scope_count = 0;
      trace.signal_capacity = 0;
      trace.scope_capacity = 0;
      trace.signal_hash_capacity = 0;
      trace.dirty_count = 0;
      trace.block_used = 0;
      trace.compressed_capacity = 0;
      free(trace.path);
      trace.path = 0;
}

static void abandon_trace_setup(void)
{
      if (trace.file) {
            fclose(trace.file);
            trace.file = 0;
      }
      release_trace_data();
}

static PLI_INT32 finish_callback(p_cb_data cause)
{
      long compressed_size = -1;

      (void)cause;
      if (trace.state != WTRACE_ACTIVE && trace.state != WTRACE_FAILED)
            return 0;

      if (trace.file) {
            if (trace.state == WTRACE_ACTIVE) {
                  write_u8(0);
                  flush_block();
                  file_write_u32(0);
                  file_write_u32(0);
            }
            compressed_size = ftell(trace.file);
            if (fclose(trace.file) != 0)
                  vpi_printf("WTRACE warning: trace file did not close cleanly.\n");
            trace.file = 0;
      }

      if (trace.state == WTRACE_ACTIVE) {
            vpi_printf("WTRACE info: wrote %s (%llu frames, %llu values",
                       trace.path ? trace.path : "wave.wtr",
                       (unsigned long long)trace.frame_count,
                       (unsigned long long)trace.value_count);
            if (compressed_size >= 0)
                  vpi_printf(", %ld bytes", compressed_size);
            vpi_printf(").\n");
            trace.state = WTRACE_CLOSED;
      }

      release_trace_data();
      return 0;
}

static int install_callbacks(void)
{
      s_cb_data callback;
      size_t idx;

      memset(&callback, 0, sizeof(callback));
      callback.reason = cbEndOfSimulation;
      callback.cb_rtn = finish_callback;
      if (!vpi_register_cb(&callback)) {
            wtrace_fail("could not register the end-of-simulation callback");
            return 0;
      }

      trace.dirty_ids = (size_t *)malloc(trace.signal_count * sizeof(size_t));
      if (!trace.dirty_ids) {
            wtrace_fail("out of memory while allocating the dirty-signal list");
            return 0;
      }

      for (idx = 0; idx < trace.signal_count; idx += 1) {
            struct wtrace_signal *signal = &trace.signals[idx];
            signal->id = idx;
            signal->last_aval = (uint32_t *)calloc(signal->word_count, sizeof(uint32_t));
            signal->last_bval = (uint32_t *)calloc(signal->word_count, sizeof(uint32_t));
            signal->next_aval = (uint32_t *)calloc(signal->word_count, sizeof(uint32_t));
            signal->next_bval = (uint32_t *)calloc(signal->word_count, sizeof(uint32_t));
            if (!signal->last_aval || !signal->last_bval ||
                !signal->next_aval || !signal->next_bval) {
                  wtrace_fail("out of memory while allocating value buffers");
                  return 0;
            }
            signal->dirty = 1;
            trace.dirty_ids[trace.dirty_count++] = idx;
            memset(&signal->callback_time, 0, sizeof(signal->callback_time));
            signal->callback_time.type = vpiSimTime;
            memset(&callback, 0, sizeof(callback));
            callback.reason = cbValueChange;
            callback.cb_rtn = dirty_callback;
            callback.obj = signal->object;
            callback.time = &signal->callback_time;
            callback.user_data = (PLI_BYTE8 *)signal;
            signal->callback = vpi_register_cb(&callback);
            if (!signal->callback) {
                  wtrace_fail("could not register a value-change callback");
                  return 0;
            }
      }

      memset(&trace.clock_time, 0, sizeof(trace.clock_time));
      trace.clock_time.type = vpiSimTime;
      memset(&callback, 0, sizeof(callback));
      callback.reason = cbValueChange;
      callback.cb_rtn = clock_callback;
      callback.obj = trace.clock;
      callback.time = &trace.clock_time;
      trace.clock_callback = vpi_register_cb(&callback);
      if (!trace.clock_callback) {
            wtrace_fail("could not register the clock callback");
            return 0;
      }

      return 1;
}

static vpiHandle resolve_scope_argument(vpiHandle argument)
{
      PLI_INT32 type;
      s_vpi_value value;

      if (!argument) return 0;
      type = vpi_get(vpiType, argument);
      if (is_scope_type(type)) return argument;

      if (type == vpiConstant || type == vpiParameter) {
            value.format = vpiStringVal;
            vpi_get_value(argument, &value);
            if (value.value.str)
                  return vpi_handle_by_name(value.value.str, 0);
      }
      return 0;
}

static PLI_INT32 wtracefile_calltf(PLI_BYTE8 *user_data)
{
      vpiHandle call = vpi_handle(vpiSysTfCall, 0);
      vpiHandle arguments = vpi_iterate(vpiArgument, call);
      vpiHandle argument;
      s_vpi_value value;
      char *path;

      (void)user_data;
      if (trace.state != WTRACE_IDLE) {
            vpi_printf("WTRACE warning: $wtracefile ignored after tracing started.\n");
            return 0;
      }
      argument = arguments ? vpi_scan(arguments) : 0;
      if (!argument || (arguments && vpi_scan(arguments))) {
            wtrace_fail("$wtracefile requires exactly one string argument");
            return 0;
      }

      value.format = vpiStringVal;
      vpi_get_value(argument, &value);
      path = wtrace_strdup(value.value.str);
      if (!path) return 0;
      free(trace.path);
      trace.path = path;
      return 0;
}

static PLI_INT32 wtracevars_calltf(PLI_BYTE8 *user_data)
{
      vpiHandle call = vpi_handle(vpiSysTfCall, 0);
      vpiHandle arguments = vpi_iterate(vpiArgument, call);
      vpiHandle clock;
      vpiHandle scope_argument;
      vpiHandle extra;
      vpiHandle scope;
      char *clock_name;
      size_t clock_idx;
      uint8_t ignored_kind;
      uint8_t header[8];
      const char *path;

      (void)user_data;
      if (trace.state != WTRACE_IDLE) {
            vpi_printf("WTRACE warning: only the first $wtracevars call is used.\n");
            return 0;
      }

      clock = arguments ? vpi_scan(arguments) : 0;
      scope_argument = arguments ? vpi_scan(arguments) : 0;
      extra = arguments ? vpi_scan(arguments) : 0;
      if (!clock || extra) {
            wtrace_fail("$wtracevars requires a clock and at most one scope");
            return 0;
      }
      if (vpi_get(vpiSize, clock) != 1) {
            wtrace_fail("the $wtracevars clock must be one bit wide");
            return 0;
      }
      if (!signal_kind(vpi_get(vpiType, clock), &ignored_kind)) {
            wtrace_fail("the $wtracevars clock must be a signal");
            return 0;
      }

      scope = scope_argument ? resolve_scope_argument(scope_argument)
                             : vpi_handle(vpiScope, call);
      if (!scope || !is_scope_type(vpi_get(vpiType, scope))) {
            wtrace_fail("the $wtracevars scope could not be resolved");
            return 0;
      }

      trace.clock = clock;
      scan_scope(scope);
      if (trace.state == WTRACE_FAILED) {
            release_trace_data();
            return 0;
      }

      clock_name = wtrace_strdup(vpi_get_str(vpiFullName, clock));
      if (!clock_name) return 0;
      clock_idx = find_signal(clock_name);
      free(clock_name);
      if (clock_idx == SIZE_MAX) {
            uint32_t clock_scope = ensure_scope(vpi_handle(vpiScope, clock));
            clock_idx = add_signal(clock, clock_scope);
      }
      if (clock_idx == SIZE_MAX) {
            wtrace_fail("could not add the clock signal to the trace");
            release_trace_data();
            return 0;
      }
      trace.signals[clock_idx].flags |= WTRACE_CLOCK_FLAG;

      qsort(trace.signals, trace.signal_count, sizeof(*trace.signals),
            compare_signals);

      path = trace.path ? trace.path : "wave.wtr";
      trace.file = fopen(path, "wb");
      if (!trace.file) {
            wtrace_fail("could not open the trace output file");
            release_trace_data();
            return 0;
      }

      trace.block = (uint8_t *)malloc(WTRACE_BLOCK_SIZE);
      trace.compressed_capacity = (size_t)LZ4_compressBound(WTRACE_BLOCK_SIZE);
      trace.compressed_block = (uint8_t *)malloc(trace.compressed_capacity);
      if (!trace.block || !trace.compressed_block) {
            wtrace_fail("out of memory while allocating LZ4 buffers");
            abandon_trace_setup();
            return 0;
      }

      memcpy(header, "WTRC", 4);
      header[4] = WTRACE_VERSION;
      header[5] = 1; /* LZ4 blocks. */
      header[6] = (uint8_t)(int8_t)vpi_get(vpiTimePrecision, 0);
      header[7] = 0; /* Both clock transitions are sampled. */
      if (!file_write(header, sizeof(header)) || !write_metadata()) {
            abandon_trace_setup();
            return 0;
      }
      trace.state = WTRACE_ACTIVE;
      if (!install_callbacks()) return 0;

      vpi_printf("WTRACE info: tracing %lu signals in %lu scopes to %s.\n",
                 (unsigned long)trace.signal_count,
                 (unsigned long)trace.scope_count, path);
      schedule_sample();
      return 0;
}

static void register_wtrace_tasks(void)
{
      s_vpi_systf_data task;

      memset(&task, 0, sizeof(task));
      task.type = vpiSysTask;
      task.tfname = "$wtracefile";
      task.calltf = wtracefile_calltf;
      vpi_register_systf(&task);

      memset(&task, 0, sizeof(task));
      task.type = vpiSysTask;
      task.tfname = "$wtracevars";
      task.calltf = wtracevars_calltf;
      vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {
      register_wtrace_tasks,
      0
};
