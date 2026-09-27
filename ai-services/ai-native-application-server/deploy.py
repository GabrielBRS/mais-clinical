#!/usr/bin/env python3
"""Publica builds/ no Jenkins e no GitLab.

As instâncias ainda não existem. O script já identifica Windows, macOS ou
Linux e reserva os comandos de terminal de cada um. Nada é enviado.
"""

from __future__ import annotations

import platform
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def operating_system() -> str:
    detected = platform.system()
    if detected == "Windows":
        return "windows"
    if detected == "Darwin":
        return "macos"
    if detected == "Linux":
        return "linux"
    raise SystemExit(f"sistema operacional não suportado: {detected}")


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


def deploy_windows(root: Path) -> None:
    run_terminal("echo sistema: Windows", root)
    run_terminal(
        'if not exist builds (echo A pasta builds nao existe. Execute python build.py & exit /b 1)',
        root,
    )
    run_terminal("dir /s /b builds", root)
    run_terminal(
        "echo Jenkins e GitLab ainda nao estao configurados. Nada foi enviado.",
        root,
    )


def deploy_macos(root: Path) -> None:
    run_terminal("echo sistema: macOS", root)
    run_terminal(
        'test -d builds || { echo "A pasta builds nao existe. Execute python build.py"; exit 1; }',
        root,
    )
    run_terminal("find builds -type f -print", root)
    run_terminal(
        'echo "Jenkins e GitLab ainda não estão configurados. Nada foi enviado."',
        root,
    )


def deploy_linux(root: Path) -> None:
    run_terminal("echo sistema: Linux", root)
    run_terminal(
        'test -d builds || { echo "A pasta builds nao existe. Execute python build.py"; exit 1; }',
        root,
    )
    run_terminal("find builds -type f -print", root)
    run_terminal(
        'echo "Jenkins e GitLab ainda não estão configurados. Nada foi enviado."',
        root,
    )


def main() -> None:
    system = operating_system()
    {
        "windows": deploy_windows,
        "macos": deploy_macos,
        "linux": deploy_linux,
    }[system](ROOT)


if __name__ == "__main__":
    sys.exit(main())
