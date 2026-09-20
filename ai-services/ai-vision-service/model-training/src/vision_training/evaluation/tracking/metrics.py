from __future__ import annotations


def mota(tp: int, fp: int, fn: int, ids: int) -> float:
    den = tp + fn
    return 0.0 if den == 0 else 1.0 - (fp + fn + ids) / den
