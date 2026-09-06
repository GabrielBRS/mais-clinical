struct ToolSchema(Copyable):
    var name: String
    var description: String

    def __init__(out self, var name: String, var description: String):
        self.name = name^
        self.description = description^


struct ToolResult(Copyable):
    var output: String
    var ok: Bool

    def __init__(out self, var output: String, ok: Bool):
        self.output = output^
        self.ok = ok
