from __future__ import annotations


def mixed_precision(name: str = "bf16") -> str:
    allowed = {"fp32", "fp16", "bf16"}
    if name not in allowed:
        raise ValueError(name)
    return name
