from __future__ import annotations


def torchrun_cmd(*, nproc: int, script: str, extra: list[str] | None = None) -> list[str]:
    return ["torchrun", f"--nproc_per_node={nproc}", script, *(extra or [])]
