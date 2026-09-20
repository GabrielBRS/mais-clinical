from __future__ import annotations

from llm_adaptation.model.loader import DummyModel


def cpt_loss(model: DummyModel, ids: list[int]) -> float:
    return model.loss(ids, ids)
