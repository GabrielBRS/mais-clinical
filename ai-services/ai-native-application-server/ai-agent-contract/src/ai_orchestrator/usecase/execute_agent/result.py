from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class ExecuteAgentResult:
    execution_id: str
    text: str
    context: list[str]
