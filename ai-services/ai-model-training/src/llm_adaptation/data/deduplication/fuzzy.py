from __future__ import annotations


def _simhash(text: str, bits: int = 64) -> int:
    vector = [0] * bits
    for token in text.lower().split():
        digest = hash(token)
        for i in range(bits):
            vector[i] += 1 if digest & (1 << i) else -1
    out = 0
    for i, value in enumerate(vector):
        if value > 0:
            out |= 1 << i
    return out


def near_duplicate(left: str, right: str, *, max_distance: int = 8) -> bool:
    return (_simhash(left) ^ _simhash(right)).bit_count() <= max_distance
