from __future__ import annotations

from llm_adaptation.data import Record


def format_pretraining(record: Record) -> str:
    return record.primary_text()
