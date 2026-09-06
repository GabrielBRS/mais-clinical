from __future__ import annotations

from dataclasses import dataclass
from uuid import uuid4


@dataclass(frozen=True, slots=True)
class AgentId:
    value: str

    @classmethod
    def new(cls, prefix: str = "agt") -> AgentId:
        return cls(f"{prefix}-{uuid4().hex[:12]}")
