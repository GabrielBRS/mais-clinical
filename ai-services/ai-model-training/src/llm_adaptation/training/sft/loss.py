from __future__ import annotations

from llm_adaptation.model.loader import DummyModel


def sft_loss(model: DummyModel, ids: list[int], labels: list[int]) -> float:
    kept = [t for t in labels if t != -100]
    return model.loss(ids, kept or ids)
