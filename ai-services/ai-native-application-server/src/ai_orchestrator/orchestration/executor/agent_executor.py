from ai_orchestrator.usecase.execute_agent import ExecuteAgentCommand, ExecuteAgentUseCase


class AgentExecutor:
    def __init__(self, usecase: ExecuteAgentUseCase) -> None:
        self._usecase = usecase

    def run(self, command: ExecuteAgentCommand):
        return self._usecase.execute(command)
