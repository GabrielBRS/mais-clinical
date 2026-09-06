from __future__ import annotations

from dataclasses import dataclass
from typing import Any


@dataclass(slots=True)
class ModelConfig:
    family: str = "qwen"
    name: str = "dummy"
    chat_template: str = "chatml"
    max_seq_len: int = 512
    vocab_size: int = 0

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> ModelConfig:
        return cls(
            family=str(data.get("family", "qwen")),
            name=str(data.get("name", "dummy")),
            chat_template=str(data.get("chat_template", "chatml")),
            max_seq_len=int(data.get("max_seq_len", 512)),
            vocab_size=int(data.get("vocab_size", 0)),
        )
