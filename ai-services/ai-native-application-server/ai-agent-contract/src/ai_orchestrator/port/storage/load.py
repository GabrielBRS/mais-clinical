from __future__ import annotations

from typing import Protocol


class StorageLoadPort(Protocol):
    def load(self, key: str) -> bytes | None: ...
