from __future__ import annotations

from pathlib import Path

from llm_adaptation.data import Record
from llm_adaptation.data.ingestion.local import load_local


def load_huggingface(uri: str) -> list[Record]:
    """Sem `datasets`: trata hf://nome como pasta em data/external/<nome>."""
    name = uri.split("://", 1)[-1].replace("/", "_")
    local = Path("data/external") / name
    if local.exists():
        return load_local(local)
    raise FileNotFoundError(f"huggingface cache ausente: {local}")
