from __future__ import annotations

from dataclasses import dataclass, field

from ai_orchestrator.domain.agent.agent_id import AgentId
from ai_orchestrator.domain.agent.capability import Capability
from ai_orchestrator.domain.agent.policy import Policy


@dataclass(slots=True)
class Agent:
    id: AgentId
    name: str
    capabilities: list[Capability] = field(default_factory=list)
    policy: Policy = field(default_factory=Policy)
    system_prompt: str = "You are a helpful orchestrator agent."
