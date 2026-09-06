from __future__ import annotations

from dataclasses import dataclass

from ai_orchestrator.domain.tool.tool_schema import ToolSchema


@dataclass(frozen=True, slots=True)
class Tool:
    schema: ToolSchema
