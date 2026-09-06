from __future__ import annotations

PRECISIONS = ("fp32", "bf16", "fp16", "int8", "int4")


def resolve_precision(name: str) -> str:
    key = name.lower()
    if key not in PRECISIONS:
        raise ValueError(f"precision desconhecida: {name}")
    return key
