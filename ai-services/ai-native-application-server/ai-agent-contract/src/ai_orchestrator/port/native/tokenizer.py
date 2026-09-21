from __future__ import annotations

from typing import Protocol


class TokenizerPort(Protocol):
    def encode(self, text: str) -> list[int]: ...
