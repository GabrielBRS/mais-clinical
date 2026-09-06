from __future__ import annotations


def channels(name: str) -> int:
    return 512 if "resnet" in name else 256
