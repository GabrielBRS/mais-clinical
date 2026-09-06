from __future__ import annotations

from typing import Protocol


class RetrievalPort(Protocol):
    def health(self) -> str: ...
    def retrieve(self, query: str, top_k: int = 8) -> list[str]: ...
