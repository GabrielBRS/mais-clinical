from __future__ import annotations

from pathlib import Path

from llm_adaptation.model.loader import DummyModel


class CheckpointCallback:
    def __init__(self, output_dir: Path) -> None:
        self.output_dir = output_dir

    def save(self, model: DummyModel, metrics: dict[str, float]) -> Path:
        del model, metrics
        path = self.output_dir
        path.mkdir(parents=True, exist_ok=True)
        return path
