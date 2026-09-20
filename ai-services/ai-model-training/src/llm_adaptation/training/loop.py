from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from llm_adaptation.data import TokenizedExample
from llm_adaptation.model.checkpoint import Checkpoint
from llm_adaptation.model.loader import DummyModel
from llm_adaptation.training.callbacks.checkpoint import CheckpointCallback
from llm_adaptation.training.callbacks.early_stopping import EarlyStopping
from llm_adaptation.training.callbacks.logging import LogCallback
from llm_adaptation.training.peft.lora import attach_lora
from llm_adaptation.training.peft.qlora import attach_qlora


@dataclass(slots=True)
class TrainConfig:
    method: str = "sft"
    adapter: str = "none"
    epochs: int = 1
    lr: float = 0.05
    lora_rank: int = 8
    lora_alpha: int = 16
    max_steps: int = 0
    output_dir: Path = Path("artifacts/checkpoints")
    extras: dict[str, Any] = field(default_factory=dict)

    @classmethod
    def from_recipe(cls, training: dict[str, Any], output_dir: Path) -> TrainConfig:
        return cls(
            method=str(training.get("method", "sft")),
            adapter=str(training.get("adapter", "none")),
            epochs=int(training.get("epochs", 1)),
            lr=float(training.get("lr", 0.05)),
            lora_rank=int(training.get("lora_rank", 8)),
            lora_alpha=int(training.get("lora_alpha", 16)),
            max_steps=int(training.get("max_steps", 0)),
            output_dir=output_dir,
            extras=training,
        )


@dataclass(slots=True)
class TrainResult:
    checkpoint: Path
    losses: list[float]
    adapter: str
    metrics: dict[str, float]


def train(model: DummyModel, examples: list[TokenizedExample], config: TrainConfig) -> TrainResult:
    if config.adapter == "lora":
        attach_lora(model, rank=config.lora_rank, alpha=config.lora_alpha)
    elif config.adapter == "qlora":
        attach_qlora(model, rank=config.lora_rank, alpha=config.lora_alpha)

    logger = LogCallback()
    stopper = EarlyStopping(patience=3)
    ckpt_cb = CheckpointCallback(config.output_dir)
    losses: list[float] = []
    step = 0
    for _ in range(max(1, config.epochs)):
        epoch_loss = 0.0
        for example in examples:
            loss = model.step(example.input_ids, example.labels, config.lr)
            epoch_loss += loss
            step += 1
            logger.on_step(step, loss)
            if config.max_steps and step >= config.max_steps:
                break
        mean = epoch_loss / max(1, len(examples))
        losses.append(mean)
        stopper.on_epoch(mean)
        if stopper.should_stop or (config.max_steps and step >= config.max_steps):
            break

    metrics = {"loss": losses[-1] if losses else 0.0, "steps": float(step)}
    path = ckpt_cb.save(model, metrics)
    Checkpoint(path=path, metrics=metrics).write(model)
    return TrainResult(checkpoint=path, losses=losses, adapter=config.adapter, metrics=metrics)
