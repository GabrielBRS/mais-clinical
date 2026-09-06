from __future__ import annotations

from typing import Protocol


class VectorSearchPort(Protocol):
    def search(self, query: str, top_k: int = 8) -> list[str]: ...
