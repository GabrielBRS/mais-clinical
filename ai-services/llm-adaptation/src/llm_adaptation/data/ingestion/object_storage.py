from __future__ import annotations

from llm_adaptation.data import Record


def load_object_storage(uri: str) -> list[Record]:
    raise NotImplementedError(f"object storage nao ligado: {uri}")
