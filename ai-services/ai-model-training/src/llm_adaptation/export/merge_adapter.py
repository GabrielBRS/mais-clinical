from __future__ import annotations

from pathlib import Path

from llm_adaptation.model.checkpoint import Checkpoint
from llm_adaptation.training.peft.merge import merge_adapter


def export_merged(checkpoint: Path, dest: Path) -> Path:
    model, ckpt = Checkpoint.read(checkpoint)
    merge_adapter(model)
    dest.mkdir(parents=True, exist_ok=True)
    Checkpoint(path=dest, metrics={**ckpt.metrics, "merged": True}).write(model)
    return dest
