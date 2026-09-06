from __future__ import annotations

import random
from typing import TypeVar

T = TypeVar("T")


def split_records(
    items: list[T],
    *,
    train: float = 0.8,
    validation: float = 0.1,
    test: float = 0.1,
    seed: int = 13,
) -> tuple[list[T], list[T], list[T]]:
    if abs(train + validation + test - 1.0) > 1e-6:
        raise ValueError("splits devem somar 1.0")
    shuffled = list(items)
    random.Random(seed).shuffle(shuffled)
    n = len(shuffled)
    n_train = int(n * train)
    n_val = int(n * validation)
    return (
        shuffled[:n_train],
        shuffled[n_train : n_train + n_val],
        shuffled[n_train + n_val :],
    )
