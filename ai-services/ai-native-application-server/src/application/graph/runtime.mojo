from application.rag.pipeline import prefix_context
from domain.errors import OrchestratorError
from domain.status import StatusCode


@fieldwise_init
struct GraphTurn(Copyable):
    var text: String
    var context: List[String]
    var steps: List[String]


struct GraphRuntime(Copyable):
    """Native retrieve/generate graph runtime."""

    var _marker: Bool

    def __init__(out self):
        self._marker = True

    def ping(self) -> String:
        return "{\"backend\":\"graph\",\"owner\":\"mojo\"}"

    def run_kinds(
        self, kinds: List[String], prompt: String, context: List[String]
    ) raises -> GraphTurn:
        if len(kinds) == 0:
            raise OrchestratorError(StatusCode.invalid_argument, "graph sem nodes")
        var steps = List[String]()
        var text = String()
        for kind in kinds:
            steps.append(kind.copy())
            if kind == "generate":
                var resolved = prompt.copy()
                if len(context) > 0:
                    resolved = prefix_context(context, prompt)
                text = "[graph] " + resolved
        return GraphTurn(text^, context.copy(), steps^)
