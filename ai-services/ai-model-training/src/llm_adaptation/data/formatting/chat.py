from __future__ import annotations

from llm_adaptation.data import Record


def format_chat(record: Record, *, bos: str = "<|im_start|>", eos: str = "<|im_end|>") -> str:
    if record.messages:
        parts = [f"{bos}{m.role}\n{m.content}{eos}" for m in record.messages]
        return "".join(parts)
    if record.instruction:
        return (
            f"{bos}user\n{record.instruction}{eos}"
            f"{bos}assistant\n{record.response}{eos}"
        )
    return record.text
