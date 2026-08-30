#!/usr/bin/env python3
"""Run a small reproducible WTRACE/VCD/FST capture comparison."""

from __future__ import annotations

import argparse
import pathlib
import statistics
import subprocess
import time


HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[1]
BUILD = HERE / "build" / "benchmark"


def run(command: list[str], *, cwd: pathlib.Path = HERE) -> str:
    result = subprocess.run(
        command,
        cwd=cwd,
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    if result.returncode:
        raise RuntimeError(f"command failed ({result.returncode}): {' '.join(command)}\n{result.stdout}")
    return result.stdout


def compile_design(mode: str, cycles: int) -> pathlib.Path:
    output = BUILD / f"benchmark-{mode}.vvp"
    command = [
        str(ROOT / "driver" / "iverilog"),
        "-g2012",
        f"-B{ROOT / 'tgt-vvp'}",
        f"-BI{ROOT}",
        f"-BM{ROOT / 'vpi'}",
        f"-BP{ROOT / 'ivlpp'}",
        f"-Ptb.CYCLES={cycles}",
        "-o",
        str(output),
    ]
    if mode != "none":
        command.append(f"-D{mode.upper()}")
    command.append(str(HERE / "tests" / "benchmark.sv"))
    run(command)
    return output


def benchmark(mode: str, image: pathlib.Path, repeats: int) -> tuple[float, int | None]:
    output_names = {"wtrace": "benchmark.wtr", "vcd": "benchmark.vcd", "fst": "benchmark.fst"}
    output = BUILD / output_names[mode] if mode in output_names else None
    command = [str(ROOT / "vvp" / "vvp")]
    if mode == "wtrace":
        command.extend([f"-M{HERE}", "-mwtrace_vpi"])
    command.append(str(image))
    if mode == "fst":
        command.append("-fst")

    timings = []
    for _ in range(repeats):
        if output and output.exists():
            output.unlink()
        started = time.perf_counter()
        run(command, cwd=BUILD)
        timings.append(time.perf_counter() - started)
    size = output.stat().st_size if output else None
    return statistics.median(timings), size


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cycles", type=int, default=10000)
    parser.add_argument("--repeats", type=int, default=3)
    args = parser.parse_args()
    if args.cycles < 1 or args.repeats < 1:
        parser.error("cycles and repeats must be positive")

    BUILD.mkdir(parents=True, exist_ok=True)
    run(["make", "wtrace_vpi.vpi"])
    images = {mode: compile_design(mode, args.cycles) for mode in ("none", "wtrace", "fst", "vcd")}
    results = {mode: benchmark(mode, image, args.repeats) for mode, image in images.items()}
    baseline = results["none"][0]

    print(f"{args.cycles} cycles, 256 state lanes, median of {args.repeats} runs")
    print(f"{'mode':<9} {'seconds':>10} {'vs baseline':>12} {'bytes':>12}")
    for mode in ("none", "wtrace", "fst", "vcd"):
        seconds, size = results[mode]
        size_text = "-" if size is None else f"{size:,}"
        print(f"{mode:<9} {seconds:>10.4f} {seconds / baseline:>11.2f}x {size_text:>12}")
    print("WTRACE is clock-boundary data; VCD/FST retain event-level behavior.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
