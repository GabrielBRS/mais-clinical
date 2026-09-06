from __future__ import annotations

from typing import Protocol

from ai_orchestrator.domain.conversation import Conversation


class MemoryLoadPort(Protocol):
    def load(self, conversation_id: str) -> Conversation | None: ...
