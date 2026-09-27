#!/usr/bin/env python3
"""Homologa os binários Linux em builds/.

Entra em cada projeto, compila dentro da pasta dele e move o artefato
para builds/<projeto>/. O projeto principal é o diretório com o mesmo
nome da raiz do repositório.
"""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
BUILDS = ROOT / "builds"
RUST_BINARY_NAME = "ai-native-runtime"
MOJO_BINARY_NAME = "agentd"


def principal_project(root: Path) -> Path:
    project = root / root.name
    if not (project / "Cargo.toml").is_file():
        raise SystemExit(f"projeto principal não encontrado: {project / 'Cargo.toml'}")
    return project


def run(command: list[str], cwd: Path) -> None:
    print(f"+ {' '.join(command)}", flush=True)
    print(f"  cwd={cwd}", flush=True)
    subprocess.run(command, cwd=cwd, check=True)


def stage(source: Path, destination: Path) -> None:
    if not source.is_file():
        raise SystemExit(f"artefato não encontrado depois da build: {source}")
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.exists():
        destination.unlink()
    shutil.move(source, destination)
    print(f"staged {destination.relative_to(ROOT)}", flush=True)


def build_rust(project: Path) -> None:
    run(["cargo", "build", "--locked", "--release"], project)
    stage(
        project / "target" / "release" / RUST_BINARY_NAME,
        BUILDS / project.name / RUST_BINARY_NAME,
    )


def build_mojo(project: Path) -> None:
    run(["pixi", "run", "--locked", "build"], project)
    stage(
        project / "build" / MOJO_BINARY_NAME,
        BUILDS / project.name / MOJO_BINARY_NAME,
    )


def main() -> None:
    if sys.platform != "linux":
        raise SystemExit("deploy.py executa no Linux (cargo e mojo de homologação).")

    build_rust(principal_project(ROOT))
    build_mojo(ROOT / "ai-agent-runtime")


if __name__ == "__main__":
    main()
