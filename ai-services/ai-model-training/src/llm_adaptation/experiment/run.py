from __future__ import annotations

from dataclasses import dataclass, field
from datetime import UTC, datetime
from uuid import uuid4


@dataclass(slots=True)
class Run:
    id: str
    name: str
    started_at: str
    metrics: dict[str, float] = field(default_factory=dict)

    @classmethod
    def start(cls, name: str) -> Run:
        return cls(
            id=f"run-{uuid4().hex[:10]}",
            name=name,
            started_at=datetime.now(UTC).isoformat(),
        )
