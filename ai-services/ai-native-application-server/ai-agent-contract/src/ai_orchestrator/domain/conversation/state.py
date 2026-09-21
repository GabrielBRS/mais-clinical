from __future__ import annotations

from enum import Enum


class ConversationState(str, Enum):
    OPEN = "open"
    WAITING_TOOL = "waiting_tool"
    CLOSED = "closed"
