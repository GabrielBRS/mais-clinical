from __future__ import annotations

from llm_adaptation.model.loader import DummyModel


def kto_loss(model: DummyModel, ids: list[int], *, desirable: bool = True) -> float:
    score = model.score(ids)
    return -score if desirable else score
