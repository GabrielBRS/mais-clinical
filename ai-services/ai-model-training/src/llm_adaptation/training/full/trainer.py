from __future__ import annotations

from llm_adaptation.data import TokenizedExample
from llm_adaptation.model.loader import DummyModel
from llm_adaptation.training.loop import TrainConfig, TrainResult, train


class FullTrainer:
    def run(self, model: DummyModel, examples: list[TokenizedExample], config: TrainConfig) -> TrainResult:
        config.adapter = "none"
        return train(model, examples, config)
