from __future__ import annotations

from typing import Protocol


class StorageSavePort(Protocol):
    def save(self, key: str, value: bytes) -> None: ...
