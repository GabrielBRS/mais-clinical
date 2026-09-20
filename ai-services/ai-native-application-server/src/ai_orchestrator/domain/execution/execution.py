from __future__ import annotations

from dataclasses import dataclass

from ai_orchestrator.domain.execution.execution_id import ExecutionId
from ai_orchestrator.domain.execution.result import ExecutionResult
from ai_orchestrator.domain.execution.status import ExecutionStatus


@dataclass(slots=True)
class Execution:
    id: ExecutionId
    status: ExecutionStatus = ExecutionStatus.PENDING
    result: ExecutionResult | None = None
    error: str | None = None
