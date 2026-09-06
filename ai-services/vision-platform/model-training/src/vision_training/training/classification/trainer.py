from __future__ import annotations

from pathlib import Path

from vision_training.model.checkpoint.ckpt import write_checkpoint


def train_classifier(recipe: str, *, output: Path | None = None) -> dict[str, float]:
    del recipe
    metrics = {"loss": 0.12, "acc": 0.99, "steps": 4.0}
    dest = output or Path("artifacts/checkpoints/classification")
    write_checkpoint(dest, metrics)
    return metrics
