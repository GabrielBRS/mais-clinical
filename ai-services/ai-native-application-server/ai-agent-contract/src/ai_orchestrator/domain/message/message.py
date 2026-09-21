from __future__ import annotations

from dataclasses import dataclass

from ai_orchestrator.domain.message.content import Content
from ai_orchestrator.domain.message.role import Role


@dataclass(frozen=True, slots=True)
class Message:
    role: Role
    content: Content

    @classmethod
    def user(cls, text: str) -> Message:
        return cls(Role.USER, Content(text))

    @classmethod
    def system(cls, text: str) -> Message:
        return cls(Role.SYSTEM, Content(text))

    @classmethod
    def assistant(cls, text: str) -> Message:
        return cls(Role.ASSISTANT, Content(text))
