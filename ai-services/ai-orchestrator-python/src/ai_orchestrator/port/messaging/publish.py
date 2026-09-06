from __future__ import annotations

from typing import Protocol


class PublishPort(Protocol):
    def publish(self, topic: str, payload: bytes) -> None: ...
