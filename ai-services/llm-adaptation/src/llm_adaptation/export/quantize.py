from __future__ import annotations

from pathlib import Path

from llm_adaptation.model.checkpoint import Checkpoint


def quantize(checkpoint: Path, dest: Path, *, bits: int = 4) -> Path:
    model, ckpt = Checkpoint.read(checkpoint)
    model.quantized = True
    dest.mkdir(parents=True, exist_ok=True)
    Checkpoint(path=dest, metrics={**ckpt.metrics, "quant_bits": bits}).write(model)
    return dest
