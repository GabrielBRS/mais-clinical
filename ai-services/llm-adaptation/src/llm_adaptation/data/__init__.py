from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


@dataclass(slots=True)
class Message:
    role: str
    content: str


@dataclass(slots=True)
class Record:
    id: str
    text: str = ""
    messages: list[Message] = field(default_factory=list)
    instruction: str = ""
    response: str = ""
    chosen: str = ""
    rejected: str = ""
    meta: dict[str, Any] = field(default_factory=dict)

    def primary_text(self) -> str:
        if self.text:
            return self.text
        if self.messages:
            return "\n".join(f"{m.role}: {m.content}" for m in self.messages)
        if self.instruction or self.response:
            return f"{self.instruction}\n{self.response}".strip()
        if self.chosen:
            return self.chosen
        return ""


@dataclass(slots=True)
class TokenizedExample:
    id: str
    input_ids: list[int]
    labels: list[int]


__all__ = ["Message", "Record", "TokenizedExample"]
