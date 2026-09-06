from __future__ import annotations

from collections.abc import Iterator
from typing import Protocol

from ai_orchestrator.domain.message import Message
from ai_orchestrator.domain.model import GenerationConfig


class StreamPort(Protocol):
    def stream(self, messages: list[Message], config: GenerationConfig) -> Iterator[str]: ...
