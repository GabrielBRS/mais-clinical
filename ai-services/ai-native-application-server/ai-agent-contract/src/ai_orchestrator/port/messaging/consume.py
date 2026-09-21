from __future__ import annotations

from typing import Protocol


class ConsumePort(Protocol):
    def consume(self, topic: str) -> bytes | None: ...
