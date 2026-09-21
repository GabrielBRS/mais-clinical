from __future__ import annotations

from dataclasses import dataclass, field

from ai_orchestrator.domain.conversation.conversation_id import ConversationId
from ai_orchestrator.domain.conversation.state import ConversationState
from ai_orchestrator.domain.message.message import Message


@dataclass(slots=True)
class Conversation:
    id: ConversationId
    messages: list[Message] = field(default_factory=list)
    state: ConversationState = ConversationState.OPEN

    def add(self, message: Message) -> None:
        self.messages.append(message)
