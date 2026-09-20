from application.application import Application
from application.commands import ExecuteAgentCommand
from domain.execution import ExecutionResult


struct ExecuteAgentUseCase(Copyable):
    """Runs one agent turn. Does not know HTTP, JSON, or status codes."""

    @staticmethod
    def execute(
        mut app: Application, command: ExecuteAgentCommand
    ) raises -> ExecutionResult:
        return app.execute_agent(
            command.agent_id, command.prompt, command.retrieve, command.backend
        )
