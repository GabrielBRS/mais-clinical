from __future__ import annotations

from typing import Protocol


class EmbedPort(Protocol):
    def embed(self, texts: list[str]) -> list[list[float]]: ...
