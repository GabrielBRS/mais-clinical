from __future__ import annotations

from llm_adaptation.model.loader import DummyModel


def ipo_loss(model: DummyModel, chosen: list[int], rejected: list[int], *, tau: float = 0.5) -> float:
    gap = model.score(chosen) - model.score(rejected) - tau
    return gap * gap
