from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from llm_adaptation.model.config import ModelConfig
from llm_adaptation.model.loader import DummyModel


@dataclass(slots=True)
class Checkpoint:
    path: Path
    metrics: dict[str, Any]

    def write(self, model: DummyModel) -> None:
        self.path.mkdir(parents=True, exist_ok=True)
        payload = {
            "family": model.config.family,
            "name": model.config.name,
            "weights": {str(k): v for k, v in model.weights.items()},
            "adapter": _jsonable(model.adapter),
            "quantized": model.quantized,
            "metrics": self.metrics,
        }
        (self.path / "checkpoint.json").write_text(json.dumps(payload, indent=2))
        (self.path / "metrics.json").write_text(json.dumps(self.metrics, indent=2))

    @classmethod
    def read(cls, path: Path) -> tuple[DummyModel, Checkpoint]:
        payload = json.loads((path / "checkpoint.json").read_text())
        config = ModelConfig(family=payload["family"], name=payload["name"])
        adapter = payload.get("adapter")
        if isinstance(adapter, dict) and isinstance(adapter.get("deltas"), dict):
            adapter = {**adapter, "deltas": {int(k): float(v) for k, v in adapter["deltas"].items()}}
        model = DummyModel(
            config=config,
            weights={int(k): float(v) for k, v in payload.get("weights", {}).items()},
            adapter=adapter,
            quantized=bool(payload.get("quantized")),
        )
        return model, cls(path=path, metrics=payload.get("metrics", {}))


def _jsonable(value: object) -> object:
    if value is None:
        return None
    if isinstance(value, dict):
        return {str(k): _jsonable(v) for k, v in value.items()}
    if isinstance(value, (str, int, float, bool)):
        return value
    return str(value)
