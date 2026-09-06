from __future__ import annotations

from typing import Protocol

from ai_orchestrator.domain.message import Message
from ai_orchestrator.domain.model import GenerationConfig


class GeneratePort(Protocol):
    def generate(self, messages: list[Message], config: GenerationConfig) -> str: ...
