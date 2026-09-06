from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class ExecuteAgentCommand:
    agent_id: str
    prompt: str
    retrieve: bool = False
