from __future__ import annotations

from llm_adaptation.model.loader import DummyModel


def pairwise_loss(model: DummyModel, chosen: list[int], rejected: list[int]) -> float:
    return max(0.0, 1.0 - (model.score(chosen) - model.score(rejected)))
