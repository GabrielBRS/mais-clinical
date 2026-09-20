from __future__ import annotations

from llm_adaptation.data import Record


def validate_record(record: Record, *, kind: str = "sft") -> list[str]:
    errors: list[str] = []
    if not record.id:
        errors.append("id vazio")
    if kind == "sft" and not (record.primary_text() or record.instruction):
        errors.append("sft sem texto")
    if kind == "preference" and not (record.chosen and record.rejected):
        errors.append("preference sem chosen/rejected")
    if kind == "pretraining" and not record.primary_text():
        errors.append("pretraining sem texto")
    return errors
