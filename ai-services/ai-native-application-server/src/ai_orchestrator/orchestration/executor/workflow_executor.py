from ai_orchestrator.usecase.execute_workflow import ExecuteWorkflowCommand, ExecuteWorkflowUseCase


class WorkflowExecutor:
    def __init__(self, usecase: ExecuteWorkflowUseCase) -> None:
        self._usecase = usecase

    def run(self, command: ExecuteWorkflowCommand):
        return self._usecase.execute(command)
