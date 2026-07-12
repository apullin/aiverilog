#!/usr/bin/env python3

import argparse
import json
from pathlib import Path
import sys


def load(path):
    return json.loads(path.read_text())


def main():
    parser = argparse.ArgumentParser(
        description="Compare two reports produced by benchmarks/run.py."
    )
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    args = parser.parse_args()

    baseline = load(args.baseline)
    candidate = load(args.candidate)
    old_names = set(baseline["workloads"])
    new_names = set(candidate["workloads"])
    if not old_names or not new_names:
        raise RuntimeError("reports contain no common workloads")
    if old_names != new_names:
        raise RuntimeError("reports contain different workload sets")
    for field in ("runs", "warmups", "phase"):
        if baseline["config"][field] != candidate["config"][field]:
            raise RuntimeError(f"reports use different {field} settings")

    print(f"baseline:  {baseline['label']} ({baseline['git']['commit']})")
    print(f"candidate: {candidate['label']} ({candidate['git']['commit']})")
    print()
    print(
        f"{'workload':16} {'phase':10} {'baseline':>12} {'candidate':>12} {'speedup':>10}"
    )

    for name in sorted(old_names):
        old = baseline["workloads"][name]
        new = candidate["workloads"][name]
        if old["sources"] != new["sources"]:
            raise RuntimeError(f"{name}: source hashes differ")
        if old["expected_stdout_sha256"] != new["expected_stdout_sha256"]:
            raise RuntimeError(f"{name}: expected output hashes differ")

        for phase in ("compile", "simulate"):
            if (phase in old) != (phase in new):
                raise RuntimeError(f"{name}: reports contain different phases")
            if phase not in old:
                continue
            old_time = old[phase]["median_seconds"]
            new_time = new[phase]["median_seconds"]
            speedup = old_time / new_time
            print(
                f"{name:16} {phase:10} {old_time:12.6f} {new_time:12.6f} {speedup:9.3f}x"
            )
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, RuntimeError, KeyError) as error:
        print(f"compare.py: {error}", file=sys.stderr)
        sys.exit(1)
