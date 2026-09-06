from ai_orchestrator.usecase.execute_tool.command import ExecuteToolCommand
from ai_orchestrator.usecase.execute_tool.result import ExecuteToolResult


class ExecuteToolUseCase:
    def execute(self, command: ExecuteToolCommand) -> ExecuteToolResult:
        if command.name == "echo":
            return ExecuteToolResult(str(command.arguments.get("text", "")), True)
        return ExecuteToolResult(f"unknown tool: {command.name}", False)
