from __future__ import annotations


def map50(scores: list[float]) -> float:
    return sum(scores) / len(scores) if scores else 0.0
