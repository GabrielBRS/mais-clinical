from __future__ import annotations


def accuracy(pred: list[int], gold: list[int]) -> float:
    if not pred:
        return 0.0
    return sum(p == g for p, g in zip(pred, gold, strict=True)) / len(pred)
