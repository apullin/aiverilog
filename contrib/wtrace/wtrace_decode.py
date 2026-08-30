#!/usr/bin/env python3
"""Decode an experimental WTRACE clock-edge trace into VCD."""

from __future__ import annotations

import argparse
import dataclasses
import pathlib
import re
import struct
import sys
from collections.abc import Iterator
from typing import BinaryIO, TextIO


MAGIC = b"WTRC"
VERSION = 1


@dataclasses.dataclass(frozen=True)
class Scope:
    parent: int | None
    kind: int
    name: str


@dataclasses.dataclass(frozen=True)
class Signal:
    scope: int
    kind: int
    flags: int
    width: int
    left: int
    right: int
    name: str


@dataclasses.dataclass(frozen=True)
class Frame:
    time: int
    changes: tuple[tuple[int, str], ...]


def _decompress_lz4_block(source: bytes, expected_size: int) -> bytes:
    """Decode the raw LZ4 block format used by the bundled Icarus LZ4."""
    output = bytearray()
    cursor = 0
    while cursor < len(source):
        token = source[cursor]
        cursor += 1

        literal_length = token >> 4
        if literal_length == 15:
            while True:
                if cursor >= len(source):
                    raise ValueError("truncated LZ4 literal length")
                extension = source[cursor]
                cursor += 1
                literal_length += extension
                if extension != 255:
                    break
        literal_end = cursor + literal_length
        if literal_end > len(source):
            raise ValueError("truncated LZ4 literals")
        if len(output) + literal_length > expected_size:
            raise ValueError("LZ4 literals exceed the declared block size")
        output.extend(source[cursor:literal_end])
        cursor = literal_end
        if cursor == len(source):
            break

        if cursor + 2 > len(source):
            raise ValueError("truncated LZ4 match offset")
        offset = source[cursor] | source[cursor + 1] << 8
        cursor += 2
        if not offset or offset > len(output):
            raise ValueError("invalid LZ4 match offset")

        match_length = token & 0x0F
        if match_length == 15:
            while True:
                if cursor >= len(source):
                    raise ValueError("truncated LZ4 match length")
                extension = source[cursor]
                cursor += 1
                match_length += extension
                if extension != 255:
                    break
        match_length += 4
        if len(output) + match_length > expected_size:
            raise ValueError("LZ4 match exceeds the declared block size")
        match_start = len(output) - offset
        for index in range(match_length):
            output.append(output[match_start + index])

    if len(output) != expected_size:
        raise ValueError("LZ4 block size does not match its declaration")
    return bytes(output)


class _LZ4BlockStream:
    def __init__(self, source: BinaryIO):
        self._source = source
        self._buffer = b""
        self._offset = 0
        self._ended = False

    def _load_block(self) -> bool:
        header = self._source.read(8)
        if len(header) != 8:
            raise ValueError("truncated WTRACE block header")
        stored_field, raw_size = struct.unpack("<II", header)
        if stored_field == 0 and raw_size == 0:
            if self._source.read(1):
                raise ValueError("data follows the WTRACE block terminator")
            self._ended = True
            return False
        if not raw_size or raw_size > 64 * 1024:
            raise ValueError("invalid WTRACE block size")

        raw_block = bool(stored_field & 0x80000000)
        stored_size = stored_field & 0x7FFFFFFF
        if not stored_size or stored_size > 64 * 1024 + (64 * 1024) // 255 + 16:
            raise ValueError("invalid WTRACE stored block size")
        stored = _read_exact(self._source, stored_size)
        if raw_block:
            if stored_size != raw_size:
                raise ValueError("raw WTRACE block has inconsistent sizes")
            self._buffer = stored
        else:
            self._buffer = _decompress_lz4_block(stored, raw_size)
        self._offset = 0
        return True

    def read(self, size: int = -1) -> bytes:
        if size < 0:
            chunks = []
            while True:
                chunk = self.read(64 * 1024)
                if not chunk:
                    return b"".join(chunks)
                chunks.append(chunk)
        result = bytearray()
        while len(result) < size:
            if self._offset == len(self._buffer):
                if self._ended or not self._load_block():
                    break
            take = min(size - len(result), len(self._buffer) - self._offset)
            result.extend(self._buffer[self._offset:self._offset + take])
            self._offset += take
        return bytes(result)


def _read_exact(stream: BinaryIO, size: int) -> bytes:
    value = stream.read(size)
    if len(value) != size:
        raise ValueError("truncated WTRACE stream")
    return value


def _read_uvarint(stream: BinaryIO) -> int:
    value = 0
    shift = 0
    for index in range(10):
        byte = _read_exact(stream, 1)[0]
        if index == 9 and byte > 1:
            raise ValueError("oversized WTRACE varint")
        value |= (byte & 0x7F) << shift
        if not byte & 0x80:
            return value
        shift += 7
    raise ValueError("oversized WTRACE varint")


def _read_svarint(stream: BinaryIO) -> int:
    value = _read_uvarint(stream)
    magnitude = value >> 1
    return -magnitude - 1 if value & 1 else magnitude


def _read_string(stream: BinaryIO) -> str:
    length = _read_uvarint(stream)
    if length > 16 * 1024 * 1024:
        raise ValueError("WTRACE string is unreasonably large")
    return _read_exact(stream, length).decode("utf-8", "surrogateescape")


def _unpack_value(packed: bytes, width: int) -> str:
    alphabet = "01xz"
    return "".join(
        alphabet[(packed[index // 4] >> (2 * (index % 4))) & 3]
        for index in range(width - 1, -1, -1)
    )


def _unpack_binary_value(packed: bytes, width: int) -> str:
    return "".join(
        "1" if packed[index // 8] & (1 << (index % 8)) else "0"
        for index in range(width - 1, -1, -1)
    )


class WTraceReader:
    def __init__(self, path: pathlib.Path | str):
        self.path = pathlib.Path(path)
        self._file = self.path.open("rb")
        self.precision = 0
        self.clock_policy = 0
        self.scopes: tuple[Scope, ...] = ()
        self.signals: tuple[Signal, ...] = ()
        try:
            self._read_header()
        except Exception:
            self._file.close()
            raise

    def _read_header(self) -> None:
        if _read_exact(self._file, 4) != MAGIC:
            raise ValueError("not a WTRACE file")
        version = _read_exact(self._file, 1)[0]
        if version != VERSION:
            raise ValueError(f"unsupported WTRACE version {version}")
        codec = _read_exact(self._file, 1)[0]
        if codec != 1:
            raise ValueError(f"unsupported WTRACE codec {codec}")
        precision_byte = _read_exact(self._file, 1)[0]
        self.precision = precision_byte - 256 if precision_byte >= 128 else precision_byte
        self.clock_policy = _read_exact(self._file, 1)[0]
        self._stream = _LZ4BlockStream(self._file)

        scopes = []
        for scope_id in range(_read_uvarint(self._stream)):
            encoded_parent = _read_uvarint(self._stream)
            parent = encoded_parent - 1 if encoded_parent else None
            if parent is not None and parent >= scope_id:
                raise ValueError("WTRACE scope table is not topologically ordered")
            kind = _read_exact(self._stream, 1)[0]
            scopes.append(Scope(parent, kind, _read_string(self._stream)))
        self.scopes = tuple(scopes)

        signals = []
        for _ in range(_read_uvarint(self._stream)):
            scope = _read_uvarint(self._stream)
            kind = _read_exact(self._stream, 1)[0]
            flags = _read_exact(self._stream, 1)[0]
            width = _read_uvarint(self._stream)
            left = _read_svarint(self._stream)
            right = _read_svarint(self._stream)
            name = _read_string(self._stream)
            if scope >= len(self.scopes) or width < 1:
                raise ValueError("invalid WTRACE signal metadata")
            signals.append(Signal(scope, kind, flags, width, left, right, name))
        self.signals = tuple(signals)

    def frames(self) -> Iterator[Frame]:
        now = 0
        while True:
            tag = _read_exact(self._stream, 1)[0]
            if tag == 0:
                trailing = self._stream.read(1)
                if trailing:
                    raise ValueError("data follows the WTRACE end marker")
                return
            if tag != 1:
                raise ValueError(f"unknown WTRACE record tag {tag}")
            now += _read_uvarint(self._stream)
            change_count = _read_uvarint(self._stream)
            changes = []
            previous = 0
            for change_index in range(change_count):
                encoded_id = _read_uvarint(self._stream)
                four_state = bool(encoded_id & 1)
                signal_id = encoded_id >> 1
                if change_index:
                    signal_id += previous
                if signal_id >= len(self.signals):
                    raise ValueError("WTRACE frame references an unknown signal")
                signal = self.signals[signal_id]
                if four_state:
                    packed = _read_exact(self._stream, (signal.width + 3) // 4)
                    value = _unpack_value(packed, signal.width)
                else:
                    packed = _read_exact(self._stream, (signal.width + 7) // 8)
                    value = _unpack_binary_value(packed, signal.width)
                changes.append((signal_id, value))
                previous = signal_id
            yield Frame(now, tuple(changes))

    def close(self) -> None:
        self._file.close()

    def __enter__(self) -> "WTraceReader":
        return self

    def __exit__(self, *unused: object) -> None:
        self.close()


_SIMPLE_IDENTIFIER = re.compile(r"[A-Za-z_][A-Za-z0-9_$]*\Z")


def _vcd_name(name: str) -> str:
    return name if _SIMPLE_IDENTIFIER.fullmatch(name) else f"\\{name} "


def _vcd_identifier(number: int) -> str:
    result = []
    while True:
        result.append(chr(33 + number % 94))
        number //= 94
        if not number:
            return "".join(result)


def _timescale(precision: int) -> str:
    units = {0: "s", -3: "ms", -6: "us", -9: "ns", -12: "ps", -15: "fs"}
    if precision > 0 or precision < -15:
        raise ValueError(f"VCD cannot represent time precision 1e{precision}s")
    unit_exponent = 3 * (precision // 3)
    return f"{10 ** (precision - unit_exponent)}{units[unit_exponent]}"


def _scope_type(kind: int) -> str:
    return {
        0: "module",
        1: "begin",
        2: "function",
        3: "task",
        4: "begin",
        5: "fork",
    }.get(kind, "module")


def _signal_type(kind: int) -> str:
    return {
        0: "wire",
        2: "integer",
        3: "time",
    }.get(kind, "reg")


def _write_declarations(reader: WTraceReader, output: TextIO) -> None:
    children: list[list[int]] = [[] for _ in reader.scopes]
    roots = []
    signals: list[list[int]] = [[] for _ in reader.scopes]
    for scope_id, scope in enumerate(reader.scopes):
        if scope.parent is None:
            roots.append(scope_id)
        else:
            children[scope.parent].append(scope_id)
    for signal_id, signal in enumerate(reader.signals):
        signals[signal.scope].append(signal_id)

    def emit_scope(scope_id: int) -> None:
        scope = reader.scopes[scope_id]
        output.write(f"$scope {_scope_type(scope.kind)} {_vcd_name(scope.name)} $end\n")
        for signal_id in signals[scope_id]:
            signal = reader.signals[signal_id]
            identifier = _vcd_identifier(signal_id)
            reference = _vcd_name(signal.name)
            vector_range = ""
            if signal.width > 1 or signal.left or signal.right:
                vector_range = f" [{signal.left}:{signal.right}]"
            output.write(
                f"$var {_signal_type(signal.kind)} {signal.width} "
                f"{identifier} {reference}{vector_range} $end\n"
            )
        for child in children[scope_id]:
            emit_scope(child)
        output.write("$upscope $end\n")

    for root in roots:
        emit_scope(root)


def decode_to_vcd(input_path: pathlib.Path, output: TextIO) -> tuple[int, int]:
    with WTraceReader(input_path) as reader:
        output.write("$version wtrace_decode.py $end\n")
        output.write(f"$timescale {_timescale(reader.precision)} $end\n")
        output.write("$comment Clock-edge samples reconstructed from WTRACE. $end\n")
        _write_declarations(reader, output)
        output.write("$enddefinitions $end\n")

        frame_count = 0
        value_count = 0
        for frame in reader.frames():
            output.write(f"#{frame.time}\n")
            for signal_id, value in frame.changes:
                identifier = _vcd_identifier(signal_id)
                if len(value) == 1:
                    output.write(f"{value}{identifier}\n")
                else:
                    output.write(f"b{value} {identifier}\n")
                value_count += 1
            frame_count += 1
        return frame_count, value_count


def _parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=pathlib.Path, help="input .wtr file")
    parser.add_argument("-o", "--output", type=pathlib.Path, help="output VCD (default: stdout)")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = _parse_args(sys.argv[1:] if argv is None else argv)
    try:
        if args.output:
            with args.output.open("w", encoding="utf-8", newline="\n") as output:
                frames, values = decode_to_vcd(args.input, output)
        else:
            frames, values = decode_to_vcd(args.input, sys.stdout)
    except (OSError, ValueError) as error:
        print(f"wtrace_decode.py: {error}", file=sys.stderr)
        return 1
    print(f"decoded {frames} frames and {values} values", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
