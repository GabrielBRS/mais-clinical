from ai_orchestrator.orchestration.runtime.context import RuntimeContext
from ai_orchestrator.orchestration.runtime.scheduler import Scheduler


class OrchestrationRuntime:
    def __init__(self) -> None:
        self.scheduler = Scheduler()

    def context(self, request_id: str) -> RuntimeContext:
        return RuntimeContext(request_id)
