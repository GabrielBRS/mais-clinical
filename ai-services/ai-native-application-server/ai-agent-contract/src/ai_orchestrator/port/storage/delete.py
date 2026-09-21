from __future__ import annotations

from typing import Protocol


class StorageDeletePort(Protocol):
    def delete(self, key: str) -> None: ...
