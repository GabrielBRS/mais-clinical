from __future__ import annotations


def deepspeed_cmd(*, zero: int, config: str, script: str) -> list[str]:
    return ["deepspeed", "--num_gpus", "auto", script, "--deepspeed", config, "--zero", str(zero)]
