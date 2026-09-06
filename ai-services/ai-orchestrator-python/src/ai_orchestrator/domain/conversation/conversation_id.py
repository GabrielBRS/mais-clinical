from __future__ import annotations

from dataclasses import dataclass
from uuid import uuid4


@dataclass(frozen=True, slots=True)
class ConversationId:
    value: str

    @classmethod
    def new(cls) -> ConversationId:
        return cls(f"cnv-{uuid4().hex[:12]}")
