from __future__ import annotations

from llm_adaptation.data import TokenizedExample
from llm_adaptation.evaluation.metrics import mean_loss, perplexity
from llm_adaptation.evaluation.safety.evaluator import evaluate_safety
from llm_adaptation.model.loader import DummyModel


def evaluate(model: DummyModel, examples: list[TokenizedExample]) -> dict[str, float]:
    metrics = {
        "loss": mean_loss(model, examples),
        "perplexity": perplexity(model, examples),
        "examples": float(len(examples)),
    }
    metrics.update(evaluate_safety())
    return metrics
