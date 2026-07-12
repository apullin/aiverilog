#!/usr/bin/env python3

import argparse
from dataclasses import dataclass
import datetime
import difflib
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import statistics
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parent


@dataclass(frozen=True)
class Workload:
    name: str
    description: str
    top: str
    sources: tuple
    gold: Path


WORKLOADS = {
    workload.name: workload
    for workload in (
        Workload(
            "event_queue",
            "event-heavy scheduling and propagation",
            "event_queue_bench",
            (ROOT / "workloads/event_queue.sv",),
            ROOT / "gold/event_queue.stdout",
        ),
        Workload(
            "vector_arith",
            "wide vector arithmetic and numeric conversion",
            "vector_arith_bench",
            (ROOT / "workloads/vector_arith.sv",),
            ROOT / "gold/vector_arith.stdout",
        ),
        Workload(
            "elaboration",
            "parameterized instance and netlist elaboration",
            "elaboration_bench",
            (ROOT / "workloads/elaboration.sv",),
            ROOT / "gold/elaboration.stdout",
        ),
        Workload(
            "event_queue_heavy",
            "event_queue scaled 8x for low-noise A/B timing",
            "event_queue_bench",
            (ROOT / "workloads/event_queue_heavy.sv",),
            ROOT / "gold/event_queue_heavy.stdout",
        ),
        Workload(
            "vector_arith_heavy",
            "vector_arith scaled 16x for low-noise A/B timing",
            "vector_arith_bench",
            (ROOT / "workloads/vector_arith_heavy.sv",),
            ROOT / "gold/vector_arith_heavy.stdout",
        ),
        Workload(
            "elaboration_heavy",
            "elaboration scaled 2x in instance count",
            "elaboration_bench",
            (ROOT / "workloads/elaboration_heavy.sv",),
            ROOT / "gold/elaboration_heavy.stdout",
        ),
    )
}


def resolve_tool(value):
    path = Path(value).expanduser()
    if path.parent != Path(".") or path.is_absolute():
        resolved = path.resolve()
        if not resolved.is_file():
            raise RuntimeError(f"tool does not exist: {resolved}")
        return resolved
    found = shutil.which(value)
    if not found:
        raise RuntimeError(f"tool is not on PATH: {value}")
    return Path(found).resolve()


def digest_file(path):
    digest = hashlib.sha256()
    with path.open("rb") as source:
        while chunk := source.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def source_label(path):
    try:
        return str(path.resolve().relative_to(ROOT))
    except ValueError:
        return path.name


def command_output(command, *, cwd=None):
    result = subprocess.run(
        command,
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    return result


def timed_run(command, *, env):
    started = time.perf_counter_ns()
    result = subprocess.run(
        command,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    elapsed = (time.perf_counter_ns() - started) / 1_000_000_000
    if result.returncode != 0:
        sys.stderr.buffer.write(result.stdout)
        sys.stderr.buffer.write(result.stderr)
        raise RuntimeError(
            f"command exited {result.returncode}: {' '.join(map(str, command))}"
        )
    return elapsed, result.stdout, result.stderr


def validate_simulation(workload, stdout, stderr):
    expected = workload.gold.read_bytes()
    if stdout == expected and not stderr:
        return

    expected_text = expected.decode("utf-8", errors="replace").splitlines(True)
    actual_text = stdout.decode("utf-8", errors="replace").splitlines(True)
    difference = "".join(
        difflib.unified_diff(
            expected_text, actual_text, fromfile="expected", tofile="actual"
        )
    )
    if stderr:
        difference += "\n--- simulator stderr ---\n"
        difference += stderr.decode("utf-8", errors="replace")
    raise RuntimeError(f"{workload.name} output mismatch\n{difference}")


def stats(samples):
    median = statistics.median(samples)
    deviations = [abs(sample - median) for sample in samples]
    return {
        "samples_seconds": samples,
        "minimum_seconds": min(samples),
        "median_seconds": median,
        "mean_seconds": statistics.mean(samples),
        "maximum_seconds": max(samples),
        "mad_seconds": statistics.median(deviations),
        "pstdev_seconds": statistics.pstdev(samples),
    }


def benchmark_phase(command, runs, warmups, env, validator=None):
    for _ in range(warmups):
        _, stdout, stderr = timed_run(command, env=env)
        if validator:
            validator(stdout, stderr)

    samples = []
    last_output = (b"", b"")
    for _ in range(runs):
        elapsed, stdout, stderr = timed_run(command, env=env)
        if validator:
            validator(stdout, stderr)
        samples.append(elapsed)
        last_output = (stdout, stderr)
    return stats(samples), last_output


def git_state():
    revision = command_output(["git", "rev-parse", "HEAD"], cwd=ROOT.parent)
    status = command_output(
        ["git", "status", "--porcelain", "--untracked-files=no"],
        cwd=ROOT.parent,
    )
    return {
        "commit": (
            revision.stdout.decode().strip() if revision.returncode == 0 else None
        ),
        "tracked_tree_dirty": (
            bool(status.stdout.strip()) if status.returncode == 0 else None
        ),
    }


def tool_metadata(path, version_flag):
    version = command_output([str(path), version_flag])
    text = (version.stdout + version.stderr).decode("utf-8", errors="replace")
    return {
        "path": str(path),
        "sha256": digest_file(path),
        "version": text.splitlines()[0] if text.splitlines() else "unknown",
    }


def parse_args():
    parser = argparse.ArgumentParser(
        description="Run reproducible Icarus compile and VVP benchmarks."
    )
    parser.add_argument("--iverilog", default="iverilog")
    parser.add_argument("--vvp", help="defaults to vvp beside --iverilog, then PATH")
    parser.add_argument(
        "--workload",
        action="append",
        choices=sorted(WORKLOADS),
        help="select one or more workloads; default: all",
    )
    parser.add_argument(
        "--phase", choices=("compile", "simulate", "both"), default="both"
    )
    parser.add_argument("--runs", type=int, default=5)
    parser.add_argument("--warmups", type=int, default=1)
    parser.add_argument("--work-dir", type=Path, default=ROOT / ".work")
    parser.add_argument("--output", type=Path)
    parser.add_argument("--label", default="unlabeled")
    parser.add_argument("--list", action="store_true")
    return parser.parse_args()


def main():
    args = parse_args()
    if args.list:
        for name, workload in WORKLOADS.items():
            print(f"{name:16} {workload.description}")
        return 0
    if args.runs < 1 or args.warmups < 0:
        raise RuntimeError("--runs must be positive and --warmups nonnegative")

    iverilog = resolve_tool(args.iverilog)
    if args.vvp:
        vvp = resolve_tool(args.vvp)
    else:
        sibling = iverilog.with_name("vvp")
        vvp = sibling if sibling.is_file() else resolve_tool("vvp")

    work_dir = args.work_dir.resolve()
    work_dir.mkdir(parents=True, exist_ok=True)
    selected = args.workload or list(WORKLOADS)
    env = os.environ.copy()
    env.update({"LC_ALL": "C", "LANG": "C", "TZ": "UTC"})

    timestamp = datetime.datetime.now(datetime.timezone.utc)
    report = {
        "schema": 1,
        "timestamp_utc": timestamp.isoformat(),
        "label": args.label,
        "platform": platform.platform(),
        "python": platform.python_version(),
        "git": git_state(),
        "config": {
            "runs": args.runs,
            "warmups": args.warmups,
            "phase": args.phase,
        },
        "tools": {
            "iverilog": tool_metadata(iverilog, "-V"),
            "vvp": tool_metadata(vvp, "-V"),
        },
        "workloads": {},
    }

    print(f"iverilog: {iverilog}")
    print(f"vvp:      {vvp}")
    print(f"runs:     {args.runs} (+ {args.warmups} warmup)")

    for name in selected:
        workload = WORKLOADS[name]
        sources = list(workload.sources)
        workload_dir = work_dir / name
        workload_dir.mkdir(parents=True, exist_ok=True)
        executable = workload_dir / f"{name}.vvp"
        compile_command = [
            str(iverilog),
            "-g2012",
            "-s",
            workload.top,
            "-o",
            str(executable),
            *(str(path) for path in sources),
        ]
        simulate_command = [str(vvp), str(executable)]
        result = {
            "description": workload.description,
            "top": workload.top,
            "sources": {source_label(path): digest_file(path) for path in sources},
            "expected_stdout_sha256": digest_file(workload.gold),
        }

        print(f"\n{name}: {workload.description}")
        if args.phase in ("compile", "both"):
            compile_stats, diagnostics = benchmark_phase(
                compile_command, args.runs, args.warmups, env
            )
            result["compile"] = compile_stats
            result["compile_stdout_sha256"] = hashlib.sha256(diagnostics[0]).hexdigest()
            result["compile_stderr_sha256"] = hashlib.sha256(diagnostics[1]).hexdigest()
            print(f"  compile median:  {compile_stats['median_seconds']:.6f} s")
        else:
            timed_run(compile_command, env=env)

        if args.phase in ("simulate", "both"):

            def validator(stdout, stderr):
                validate_simulation(workload, stdout, stderr)

            simulate_stats, _ = benchmark_phase(
                simulate_command, args.runs, args.warmups, env, validator
            )
            result["simulate"] = simulate_stats
            print(f"  simulate median: {simulate_stats['median_seconds']:.6f} s")

        report["workloads"][name] = result

    if args.output:
        output_path = args.output.resolve()
    else:
        stamp = timestamp.strftime("%Y%m%dT%H%M%SZ")
        safe_label = "".join(
            character if character.isalnum() or character in ".-_" else "_"
            for character in args.label
        )
        output_path = work_dir / "results" / f"{stamp}-{safe_label}.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print(f"\nreport: {output_path}")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"run.py: {error}", file=sys.stderr)
        sys.exit(1)
