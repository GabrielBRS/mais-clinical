from __future__ import annotations


def length_reward(text: str, *, target: int = 32) -> float:
    return -abs(len(text.split()) - target) / max(1, target)
