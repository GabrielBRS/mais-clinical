from __future__ import annotations

from typing import Protocol

from ai_orchestrator.domain.conversation import Conversation


class MemorySavePort(Protocol):
    def save(self, conversation: Conversation) -> None: ...
