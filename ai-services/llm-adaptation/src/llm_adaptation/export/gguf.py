from __future__ import annotations

from pathlib import Path

from llm_adaptation.model.loader import DummyModel


def write_gguf(model: DummyModel, dest: Path) -> Path:
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(b"GGUF-STUB\n" + model.config.name.encode())
    return dest
