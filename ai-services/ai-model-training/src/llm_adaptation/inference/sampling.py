from __future__ import annotations

import random


def sample_id(weights: dict[int, float], *, temperature: float = 1.0, rng: random.Random | None = None) -> int:
    rng = rng or random.Random()
    if not weights:
        return 0
    temp = max(1e-6, temperature)
    items = [(i, w / temp) for i, w in weights.items()]
    items.sort(key=lambda x: x[1], reverse=True)
    return items[0][0] if temp <= 0.2 else rng.choice([i for i, _ in items[:8]])
