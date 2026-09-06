from __future__ import annotations

from llm_adaptation.model.loader import DummyModel


def merge_adapter(model: DummyModel) -> DummyModel:
    if not model.adapter:
        return model
    scale = float(model.adapter.get("scale", 1.0))
    deltas = model.adapter.get("deltas", {})
    for key, value in deltas.items():  # type: ignore[union-attr]
        token = int(key)
        model.weights[token] = model.weights.get(token, 0.0) + scale * float(value)
    model.adapter = None
    model.quantized = False
    return model
