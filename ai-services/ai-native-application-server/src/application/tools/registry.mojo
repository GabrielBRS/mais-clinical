from domain.tool import ToolResult


struct ToolRegistry(Copyable):
    var _marker: Bool

    def __init__(out self):
        self._marker = True

    def execute(self, name: String, argument: String) -> ToolResult:
        if name == "echo":
            return ToolResult(argument, True)
        return ToolResult("unknown tool: " + name, False)
