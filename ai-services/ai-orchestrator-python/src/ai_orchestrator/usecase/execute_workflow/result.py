from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class ExecuteWorkflowResult:
    text: str
    steps: list[str]
