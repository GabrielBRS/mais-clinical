from __future__ import annotations

from llm_adaptation.data import Record


def summarize(records: list[Record]) -> dict[str, float | int]:
    lengths = [len(r.primary_text()) for r in records]
    return {
        "count": len(records),
        "avg_chars": (sum(lengths) / len(lengths)) if lengths else 0.0,
        "max_chars": max(lengths, default=0),
        "min_chars": min(lengths, default=0),
        "with_messages": sum(1 for r in records if r.messages),
        "with_preference": sum(1 for r in records if r.chosen and r.rejected),
    }
