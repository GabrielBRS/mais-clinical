from __future__ import annotations

from typing import Protocol


class InferencePort(Protocol):
    def health(self) -> str: ...
    def generate(self, prompt: str) -> str: ...
