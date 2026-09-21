from __future__ import annotations

from dataclasses import dataclass
from uuid import uuid4


@dataclass(frozen=True, slots=True)
class ExecutionId:
    value: str

    @classmethod
    def new(cls) -> ExecutionId:
        return cls(f"exe-{uuid4().hex[:12]}")
