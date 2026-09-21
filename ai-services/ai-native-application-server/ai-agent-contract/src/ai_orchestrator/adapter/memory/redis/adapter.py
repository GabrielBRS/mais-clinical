from __future__ import annotations

from ai_orchestrator.domain.conversation import Conversation


class RedisMemory:
    """In-process até o Redis de verdade ser ligado."""

    def __init__(self) -> None:
        self._store: dict[str, Conversation] = {}

    def load(self, conversation_id: str) -> Conversation | None:
        return self._store.get(conversation_id)

    def save(self, conversation: Conversation) -> None:
        self._store[conversation.id.value] = conversation
