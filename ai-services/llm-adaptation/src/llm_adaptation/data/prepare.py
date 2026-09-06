"""Pipeline de dados usado por `pipeline.prepare` e pelos scripts."""

from __future__ import annotations

from llm_adaptation.data import Record
from llm_adaptation.data.cleaning import latin_ratio, normalize, sanitize
from llm_adaptation.data.deduplication.exact import exact_key
from llm_adaptation.data.filtering import length_ok, quality_ok, toxicity_hit


def clean_record(record: Record) -> Record:
    record.text = normalize(sanitize(record.text))
    record.instruction = normalize(sanitize(record.instruction))
    record.response = normalize(sanitize(record.response))
    record.chosen = normalize(sanitize(record.chosen))
    record.rejected = normalize(sanitize(record.rejected))
    for message in record.messages:
        message.content = normalize(sanitize(message.content))
    return record


def keep_record(record: Record, *, min_latin: float = 0.6) -> bool:
    text = record.primary_text()
    return (
        length_ok(text)
        and quality_ok(text)
        and not toxicity_hit(text)
        and latin_ratio(text) >= min_latin
    )


def dedupe(records: list[Record]) -> list[Record]:
    seen: set[str] = set()
    unique: list[Record] = []
    for record in records:
        key = exact_key(record.primary_text())
        if key in seen:
            continue
        seen.add(key)
        unique.append(record)
    return unique


def prepare_records(records: list[Record]) -> list[Record]:
    cleaned = [clean_record(record) for record in records]
    kept = [record for record in cleaned if keep_record(record)]
    return dedupe(kept)
