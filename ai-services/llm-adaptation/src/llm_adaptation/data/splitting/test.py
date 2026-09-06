from __future__ import annotations

from typing import TypeVar

from llm_adaptation.data.splitting.train import split_records

T = TypeVar("T")


def test_split(items: list[T], *, ratio: float = 0.1, seed: int = 13) -> list[T]:
    _, _, test = split_records(items, train=1.0 - ratio, validation=0.0, test=ratio, seed=seed)
    return test
