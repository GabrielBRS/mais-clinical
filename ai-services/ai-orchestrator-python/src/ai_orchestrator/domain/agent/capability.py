from __future__ import annotations

from enum import Enum


class Capability(str, Enum):
    GENERATE = "generate"
    RETRIEVE = "retrieve"
    TOOL = "tool"
    WORKFLOW = "workflow"
