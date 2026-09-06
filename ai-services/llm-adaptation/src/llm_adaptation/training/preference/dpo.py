from __future__ import annotations

from llm_adaptation.model.loader import DummyModel


def dpo_loss(model: DummyModel, chosen: list[int], rejected: list[int], *, beta: float = 0.1) -> float:
    margin = model.score(chosen) - model.score(rejected)
    return -beta * margin
