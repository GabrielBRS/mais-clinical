from __future__ import annotations

from llm_adaptation.model.loader import DummyModel
from llm_adaptation.training.peft.lora import attach_lora


def attach_qlora(model: DummyModel, *, rank: int = 8, alpha: int = 16) -> DummyModel:
    attach_lora(model, rank=rank, alpha=alpha)
    assert model.adapter is not None
    model.adapter["kind"] = "qlora"
    model.adapter["quant"] = "int4"
    model.quantized = True
    return model
