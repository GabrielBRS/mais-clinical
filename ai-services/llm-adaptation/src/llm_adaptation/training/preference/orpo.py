from __future__ import annotations

from llm_adaptation.model.loader import DummyModel
from llm_adaptation.training.preference.dpo import dpo_loss


def orpo_loss(model: DummyModel, chosen: list[int], rejected: list[int]) -> float:
    nll = model.loss(chosen, chosen)
    return nll + dpo_loss(model, chosen, rejected)
