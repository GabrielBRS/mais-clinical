from application.application import Application
from application.commands import ExecuteWorkflowCommand
from domain.execution import ExecutionResult


struct ExecuteWorkflowUseCase(Copyable):
    """Runs the default retrieve→generate graph. Transport-agnostic."""

    @staticmethod
    def execute(
        mut app: Application, command: ExecuteWorkflowCommand
    ) raises -> ExecutionResult:
        return app.execute_workflow(command.prompt)
