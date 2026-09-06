from __future__ import annotations

from dataclasses import dataclass, field

from llm_adaptation.model.config import ModelConfig


@dataclass(slots=True)
class DummyModel:
    """Unigrama treinável. Troca por HF/transformers no mesmo port."""

    config: ModelConfig
    weights: dict[int, float] = field(default_factory=dict)
    adapter: dict[str, object] | None = None
    quantized: bool = False

    def score(self, ids: list[int]) -> float:
        if not ids:
            return 0.0
        base = sum(self.weights.get(i, 0.0) for i in ids) / len(ids)
        if not self.adapter:
            return base
        deltas = self.adapter.get("deltas", {})
        extra = sum(float(deltas.get(i, 0.0)) for i in ids) / len(ids)  # type: ignore[arg-type]
        scale = float(self.adapter.get("scale", 1.0))
        return base + scale * extra

    def loss(self, ids: list[int], labels: list[int]) -> float:
        del ids
        return -self.score(labels)

    def step(self, ids: list[int], labels: list[int], lr: float) -> float:
        current = self.loss(ids, labels)
        target = self.adapter["deltas"] if self.adapter is not None else self.weights  # type: ignore[assignment]
        for token in labels:
            target[token] = float(target.get(token, 0.0)) + lr  # type: ignore[index]
        return current


def load_model(config: ModelConfig) -> DummyModel:
    return DummyModel(config=config)
