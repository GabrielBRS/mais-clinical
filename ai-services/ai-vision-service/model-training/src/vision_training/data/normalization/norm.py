from __future__ import annotations


def imagenet(value: float) -> float:
    return (value / 255.0 - 0.485) / 0.229
