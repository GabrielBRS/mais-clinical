from ai_orchestrator.domain.execution import ExecutionStatus


def next_status(current: ExecutionStatus, event: str) -> ExecutionStatus:
    if event == "start":
        return ExecutionStatus.RUNNING
    if event == "ok":
        return ExecutionStatus.SUCCEEDED
    if event == "fail":
        return ExecutionStatus.FAILED
    return current
