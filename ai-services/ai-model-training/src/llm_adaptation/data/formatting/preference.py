from __future__ import annotations

from llm_adaptation.data import Record


def format_preference(record: Record) -> tuple[str, str]:
    prompt = record.instruction or record.primary_text()
    chosen = record.chosen or record.response
    rejected = record.rejected
    return f"{prompt}\n{chosen}".strip(), f"{prompt}\n{rejected}".strip()
