/*
 * Copyright (c) 2026 Andrew Pullin
 *
 *    This source code is free software; you can redistribute it
 *    and/or modify it in source code form under the terms of the GNU
 *    General Public License as published by the Free Software
 *    Foundation; either version 2 of the License, or (at your option)
 *    any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *    General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

# include "config.h"
# include "codes.h"
# include "vthread.h"
# include "vvp_net.h"
# include <cassert>
# include <cstring>
# include "vvp_net_sig.h"

/* Append new handlers without shifting the established hot opcode layout. */
#if defined(__ELF__)
# define VVP_TEXT_TAIL __attribute__((section(".vvp_text_tail")))
#else
# define VVP_TEXT_TAIL
#endif

/* Apply an immediate XOR directly to the vector stack's top value. */
VVP_TEXT_TAIL
bool of_XORI(vthread_t thr, vvp_code_t cp)
{
      const vvp_vector4_t&top = vthread_get_vec4_stack(thr, 0);
	// The public stack accessor is read-only; this opcode deliberately
	// updates the existing top value in place to avoid a pop and push.
      vvp_vector4_t&val = const_cast<vvp_vector4_t&>(top);

      val.xor_immediate(cp->bit_idx[0], cp->bit_idx[1], cp->number);
      return true;
}

/* Slow reduce4 loop (renamed from reduce4 in vvp_net.cc so the fast
 * path below interposes under the original mangled name). */
extern vvp_vector4_t reduce4_slow_(const vvp_vector8_t&that);

/* Strength-free reduce4 fast path, interposing under reduce4's own
 * symbol so every existing caller benefits with no changes at call
 * sites and no .text growth in vvp_net.o. Gate outputs are almost
 * always plain 0/1, so decode the strength bytes directly into the
 * out words instead of per-bit value()/set_bit() calls. Any byte
 * needing strength, HiZ, or X handling falls back to the exact slow
 * loop (which fully overwrites out, so partial fills here are
 * harmless). Bit mapping mirrors vvp_scalar_t::value: hiz (low 7
 * bits clear) is excluded, 0x00 is 0, 0x88 is 1, anything else falls
 * back. */
VVP_TEXT_TAIL
bool reduce4_plain_(const vvp_vector8_t&that, vvp_vector4_t&out)
{
      const unsigned BPW = 8 * sizeof(unsigned long);
      unsigned n = that.size_;
      const unsigned char*bytes
	    = (n <= sizeof(that.val_)) ? that.val_ : that.ptr_;
      assert(out.size_ == n);
      if (n <= BPW) {
	    unsigned long ab = 0;
	    for (unsigned idx = 0 ; idx < n ; idx += 1) {
		  unsigned b = bytes[idx];
		  if ((b & 0x77) == 0)
			return false;
		  unsigned v = b & 0x88;
		  if (v == 0x88)
			ab |= 1UL << idx;
		  else if (v != 0x00)
			return false;
	    }
	    out.abits_val_ = ab;
	    out.bbits_val_ = 0;
	    return true;
      }
      unsigned words = (n + BPW - 1) / BPW;
      memset(out.abits_ptr_, 0, words * sizeof(unsigned long));
      memset(out.bbits_ptr_, 0, words * sizeof(unsigned long));
      for (unsigned idx = 0 ; idx < n ; idx += 1) {
	    unsigned b = bytes[idx];
	    if ((b & 0x77) == 0)
		  return false;
	    unsigned v = b & 0x88;
	    if (v == 0x88)
		  out.abits_ptr_[idx / BPW] |= 1UL << (idx % BPW);
	    else if (v != 0x00)
		  return false;
      }
      return true;
}

/* Interpose under reduce4's symbol: fast path first, exact slow loop
 * on fallback. Same signature as the original, so the mangled name
 * matches what existing callers reference. */
VVP_TEXT_TAIL
vvp_vector4_t reduce4(const vvp_vector8_t&that)
{
      vvp_vector4_t out (that.size());
      if (reduce4_plain_(that, out))
	    return out;
      return reduce4_slow_(that);
}

/* Loader-fused %load/vec4 + %parti/s|u (single bit) + %replicate, the
 * sign-extension idiom. The selected bit fills the result directly:
 * the fill constructor sets every word, so one construction replaces
 * the %parti temporary plus rept set_vec stamps exactly (the per-bit
 * read X-pads out-of-range exactly like %parti). The fused slot keeps
 * the load operands; the replicate count lives on in the dead
 * %replicate slot's number field (cp+2). */
VVP_TEXT_TAIL
bool of_LOAD_PARTI_REPLICATE(vthread_t thr, vvp_code_t cp)
{
      /* The fused operation lives in the %replicate slot, so the dead
       * %load/%parti slots execute as %noop first and control arrives
       * here with no skip needed. The load operands live two slots
       * back; the replicate count is this slot's own number. */
      vvp_code_t load = cp - 2;
      unsigned use_base = (unsigned)(int32_t)load->bit_idx[0];
      vvp_vector4_t fill(cp->number, load->signal->value(use_base));
      vthread_push(thr, fill);
      return true;
}
