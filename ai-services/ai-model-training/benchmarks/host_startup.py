"""Measure host and CPython boundary startup without writing benchmark artifacts."""

from __future__ import annotations

import json
import os
from pathlib import Path
from statistics import median
import subprocess
import sys
from time import perf_counter


ROOT = Path(__file__).resolve().parents[1]
BINARY = ROOT / "build/ai-model-training"
REPEATS = 5


def measure(command: list[str], env: dict[str, str] | None = None) -> float:
    samples: list[float] = []
    for _ in range(REPEATS):
        started = perf_counter()
        subprocess.run(command, cwd=ROOT, env=env, capture_output=True, check=True)
        samples.append((perf_counter() - started) * 1000)
    return median(samples)


def main() -> None:
    if not BINARY.exists():
        raise SystemExit("build/ai-model-training is missing; run `pixi run build`")
    env = os.environ.copy()
    mojo_only = measure([str(BINARY), "--help"], env)
    mojo_cpython = measure([str(BINARY), "health"], env)
    python_facade = measure(
        [
            sys.executable,
            "-c",
            "from llm_adaptation.host_api import execute; execute({'operation':'health'})",
        ],
        env,
    )
    print(
        json.dumps(
            {
                "repeats": REPEATS,
                "median_ms": {
                    "mojo_cli_without_cpython": round(mojo_only, 3),
                    "mojo_cpython_health_total": round(mojo_cpython, 3),
                    "python_facade_process_total": round(python_facade, 3),
                    "estimated_cpython_and_boundary_increment": round(mojo_cpython - mojo_only, 3),
                },
                "notes": [
                    "The increment is an estimate, not a kernel benchmark.",
                    "The current engine is a CPU dummy and has no PyTorch/CUDA import cost.",
                ],
            },
            indent=2,
            sort_keys=True,
        )
    )


if __name__ == "__main__":
    main()
