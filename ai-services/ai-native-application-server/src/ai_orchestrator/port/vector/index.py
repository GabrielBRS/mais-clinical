from __future__ import annotations

from typing import Protocol


class VectorIndexPort(Protocol):
    def index(self, texts: list[str]) -> int: ...
