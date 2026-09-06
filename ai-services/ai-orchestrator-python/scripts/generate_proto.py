#!/usr/bin/env python3
"""Gera stubs em src/ai_orchestrator/generated/proto/."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROTO = ROOT / "proto"
OUT = ROOT / "src" / "ai_orchestrator" / "generated" / "proto"


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    cmd = [
        sys.executable,
        "-m",
        "grpc_tools.protoc",
        f"-I{PROTO}",
        f"--python_out={OUT}",
        f"--grpc_python_out={OUT}",
        str(PROTO / "common.proto"),
        str(PROTO / "agent.proto"),
        str(PROTO / "inference.proto"),
        str(PROTO / "retrieval.proto"),
    ]
    subprocess.check_call(cmd)
    print(f"generated into {OUT}")


if __name__ == "__main__":
    main()
