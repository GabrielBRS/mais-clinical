from __future__ import annotations

from llm_adaptation.data import Record


def format_instruction(record: Record) -> str:
    if record.instruction:
        return f"### Instruction\n{record.instruction}\n\n### Response\n{record.response}".strip()
    return record.primary_text()
