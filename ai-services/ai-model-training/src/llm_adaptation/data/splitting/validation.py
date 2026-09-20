from __future__ import annotations

from typing import TypeVar

from llm_adaptation.data.splitting.train import split_records

T = TypeVar("T")


def validation_split(items: list[T], *, ratio: float = 0.1, seed: int = 13) -> list[T]:
    _, val, _ = split_records(items, train=1.0 - ratio, validation=ratio, test=0.0, seed=seed)
    return val
