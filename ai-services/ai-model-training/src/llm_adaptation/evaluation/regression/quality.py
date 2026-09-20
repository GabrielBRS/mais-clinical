from __future__ import annotations


def quality_regressed(current: float, baseline: float, *, tolerance: float = 0.05) -> bool:
    return current + tolerance < baseline
