from __future__ import annotations

from llm_adaptation.data import TokenizedExample
from llm_adaptation.model.loader import DummyModel


def mean_loss(model: DummyModel, examples: list[TokenizedExample]) -> float:
    if not examples:
        return 0.0
    return sum(model.loss(ex.input_ids, ex.labels) for ex in examples) / len(examples)
