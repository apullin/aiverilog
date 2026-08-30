#!/usr/bin/env python3
"""Semantic check for the WTRACE smoke-test capture."""

from __future__ import annotations

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

from wtrace_decode import WTraceReader  # noqa: E402


def full_names(reader: WTraceReader) -> list[str]:
    scope_names: list[str] = []
    for scope in reader.scopes:
        parent = "" if scope.parent is None else scope_names[scope.parent] + "."
        scope_names.append(parent + scope.name)
    return [scope_names[signal.scope] + "." + signal.name for signal in reader.signals]


def main() -> int:
    path = pathlib.Path(sys.argv[1])
    with WTraceReader(path) as reader:
        names = full_names(reader)
        by_name = {name: idx for idx, name in enumerate(names)}
        required = {
            "tb.clk",
            "tb.dut.count",
            "tb.dut.four_state",
            "tb.dut.ascending",
            "tb.dut.glitch",
            "tb.dut.memory[0]",
            "tb.dut.memory[3]",
        }
        missing = required - by_name.keys()
        assert not missing, f"missing signals: {sorted(missing)}"
        assert sum(bool(signal.flags & 1) for signal in reader.signals) == 1

        frames = list(reader.frames())
        assert [frame.time for frame in frames] == list(range(0, 40001, 5000))

        current: dict[int, str] = {}
        snapshots = []
        glitch_updates = 0
        glitch_id = by_name["tb.dut.glitch"]
        for frame in frames:
            for signal_id, value in frame.changes:
                current[signal_id] = value
                if signal_id == glitch_id:
                    glitch_updates += 1
            snapshots.append(dict(current))

        count_id = by_name["tb.dut.count"]
        assert [int(state[count_id], 2) for state in snapshots] == [0, 1, 1, 2, 2, 3, 3, 4, 4]

        four_id = by_name["tb.dut.four_state"]
        assert [state[four_id] for state in snapshots] == [
            "10xz", "10xz", "0xz1", "0xz1", "xz10",
            "xz10", "z10x", "z10x", "10xz",
        ]

        ascending_id = by_name["tb.dut.ascending"]
        assert all(state[ascending_id] == "01xz" for state in snapshots)

        # This signal toggles and returns between clock edges. Edge sampling
        # intentionally collapses the transient, so only its initial value is stored.
        assert glitch_updates == 1
        assert snapshots[-1][glitch_id] == "0"

    print("WTRACE semantic check passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
