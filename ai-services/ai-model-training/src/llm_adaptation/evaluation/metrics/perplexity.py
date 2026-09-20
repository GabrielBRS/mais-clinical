from __future__ import annotations

import math

from llm_adaptation.data import TokenizedExample
from llm_adaptation.evaluation.metrics.loss import mean_loss
from llm_adaptation.model.loader import DummyModel


def perplexity(model: DummyModel, examples: list[TokenizedExample]) -> float:
    loss = mean_loss(model, examples)
    return math.exp(min(20.0, max(-20.0, loss)))
