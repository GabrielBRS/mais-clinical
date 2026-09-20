from __future__ import annotations


def capability_drop(current: dict[str, float], baseline: dict[str, float], *, min_keep: float = 0.95) -> list[str]:
    dropped: list[str] = []
    for key, base in baseline.items():
        if base <= 0:
            continue
        if current.get(key, 0.0) / base < min_keep:
            dropped.append(key)
    return dropped
