from __future__ import annotations

from llm_adaptation.model.loader import DummyModel
from llm_adaptation.training.peft.targets import default_targets


def attach_lora(model: DummyModel, *, rank: int = 8, alpha: int = 16) -> DummyModel:
    model.adapter = {
        "kind": "lora",
        "rank": rank,
        "alpha": alpha,
        "scale": alpha / max(1, rank),
        "targets": list(default_targets(model.config.family)),
        "deltas": {},
    }
    model.quantized = False
    return model
