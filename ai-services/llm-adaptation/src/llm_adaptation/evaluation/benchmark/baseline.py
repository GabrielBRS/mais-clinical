from __future__ import annotations


def delta(current: dict[str, float], baseline: dict[str, float]) -> dict[str, float]:
    return {key: current.get(key, 0.0) - baseline.get(key, 0.0) for key in {*current, *baseline}}
