from __future__ import annotations

from pathlib import Path

from llm_adaptation.data import Record
from llm_adaptation.data.ingestion.huggingface import load_huggingface
from llm_adaptation.data.ingestion.local import load_local
from llm_adaptation.data.ingestion.object_storage import load_object_storage


def load_records(source: str | Path) -> list[Record]:
    text = str(source)
    if text.startswith(("s3://", "gs://", "az://")):
        return load_object_storage(text)
    if text.startswith("hf://") or text.startswith("huggingface://"):
        return load_huggingface(text)
    return load_local(Path(text))
