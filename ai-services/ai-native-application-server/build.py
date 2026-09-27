#!/usr/bin/env python3
"""Compila os projetos e move os binários para builds/.

Quem executa é a máquina do funcionário. O script identifica Windows, macOS
ou Linux e dispara os comandos de terminal desse sistema.
"""

from __future__ import annotations

import platform
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
RUST_BINARY = "ai-native-runtime"
MOJO_BINARY = "agentd"


def operating_system() -> str:
    detected = platform.system()
    if detected == "Windows":
        return "windows"
    if detected == "Darwin":
        return "macos"
    if detected == "Linux":
        return "linux"
    raise SystemExit(f"sistema operacional não suportado: {detected}")


def principal_project(root: Path) -> Path:
    project = root / root.name
    if not (project / "Cargo.toml").is_file():
        raise SystemExit(f"projeto principal não encontrado: {project / 'Cargo.toml'}")
    return project


def run_terminal(script: str, cwd: Path) -> None:
    system = operating_system()
    print(f"[{system}] {script}", flush=True)
    print(f"  cwd={cwd}", flush=True)
    if system == "windows":
        command = ["cmd", "/c", script]
    elif system == "macos":
        command = ["zsh", "-lc", script]
    else:
        command = ["bash", "-lc", script]
    completed = subprocess.run(command, cwd=cwd)
    if completed.returncode != 0:
        raise SystemExit(completed.returncode)


def q(value: str) -> str:
    return f'"{value}"'


def build_windows(root: Path) -> None:
    project = principal_project(root).name
    rust_binary = f"{RUST_BINARY}.exe"
    run_terminal("echo sistema: Windows", root)
    run_terminal(f"cd /d {q(project)} && cargo build --locked --release", root)
    run_terminal(
        " && ".join(
            [
                f'if not exist {q(f"builds\\{project}")} mkdir {q(f"builds\\{project}")}',
                f'if not exist {q(f"{project}\\target\\release\\{rust_binary}")} exit /b 1',
                f'move /Y {q(f"{project}\\target\\release\\{rust_binary}")} {q(f"builds\\{project}\\{rust_binary}")}',
            ]
        ),
        root,
    )
    run_terminal("cd /d ai-agent-runtime && pixi run --locked build", root)
    run_terminal(
        " && ".join(
            [
                'if not exist "builds\\ai-agent-runtime" mkdir "builds\\ai-agent-runtime"',
                'if not exist "ai-agent-runtime\\build\\agentd" exit /b 1',
                f'move /Y "ai-agent-runtime\\build\\agentd" {q(f"builds\\ai-agent-runtime\\{MOJO_BINARY}")}',
            ]
        ),
        root,
    )


def build_macos(root: Path) -> None:
    project = principal_project(root).name
    run_terminal("echo sistema: macOS", root)
    run_terminal(f"cd {q(project)} && cargo build --locked --release", root)
    run_terminal(
        f"mkdir -p {q(f'builds/{project}')} "
        f"&& test -f {q(f'{project}/target/release/{RUST_BINARY}')} "
        f"&& mv -f {q(f'{project}/target/release/{RUST_BINARY}')} {q(f'builds/{project}/{RUST_BINARY}')}",
        root,
    )
    run_terminal("cd ai-agent-runtime && pixi run --locked build", root)
    run_terminal(
        f"mkdir -p {q('builds/ai-agent-runtime')} "
        f"&& test -f {q(f'ai-agent-runtime/build/{MOJO_BINARY}')} "
        f"&& mv -f {q(f'ai-agent-runtime/build/{MOJO_BINARY}')} {q(f'builds/ai-agent-runtime/{MOJO_BINARY}')}",
        root,
    )


def build_linux(root: Path) -> None:
    project = principal_project(root).name
    run_terminal("echo sistema: Linux", root)
    run_terminal(f"cd {q(project)} && cargo build --locked --release", root)
    run_terminal(
        f"mkdir -p {q(f'builds/{project}')} "
        f"&& test -f {q(f'{project}/target/release/{RUST_BINARY}')} "
        f"&& mv -f {q(f'{project}/target/release/{RUST_BINARY}')} {q(f'builds/{project}/{RUST_BINARY}')}",
        root,
    )
    run_terminal("cd ai-agent-runtime && pixi run --locked build", root)
    run_terminal(
        f"mkdir -p {q('builds/ai-agent-runtime')} "
        f"&& test -f {q(f'ai-agent-runtime/build/{MOJO_BINARY}')} "
        f"&& mv -f {q(f'ai-agent-runtime/build/{MOJO_BINARY}')} {q(f'builds/ai-agent-runtime/{MOJO_BINARY}')}",
        root,
    )


def main() -> None:
    system = operating_system()
    {
        "windows": build_windows,
        "macos": build_macos,
        "linux": build_linux,
    }[system](ROOT)


if __name__ == "__main__":
    sys.exit(main())
