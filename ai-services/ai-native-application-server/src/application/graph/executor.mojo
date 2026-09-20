from application.rag.pipeline import prefix_context
from domain.execution import ExecutionResult
from domain.message import Message
from domain.model import GenerationConfig
from infrastructure.local.llm import LocalLlm
from infrastructure.local.vector import InMemoryVector

from .graph import Graph


struct GraphExecutor(Copyable):
    var graph: Graph
    var llm: LocalLlm
    var vector: InMemoryVector
    var next_id: Int

    def __init__(
        out self,
        var graph: Graph,
        var llm: LocalLlm,
        var vector: InMemoryVector,
    ):
        self.graph = graph^
        self.llm = llm^
        self.vector = vector^
        self.next_id = 1

    def execute(mut self, prompt: String) raises -> ExecutionResult:
        var steps = List[String]()
        var context = List[String]()
        var resolved = prompt.copy()
        var node = self.graph.start()
        var visited = List[String]()
        while not _contains(visited, node.id):
            visited.append(node.id.copy())
            steps.append(node.kind.copy())
            if node.kind == "retrieve":
                context = self.vector.search(prompt, 3)
                if len(context) > 0:
                    resolved = prefix_context(context, prompt)
            elif node.kind == "generate":
                var text = self._generate(resolved)
                return ExecutionResult(text, context^, steps^, self._new_id())
            var nxt = self.graph.successors(node.id)
            if len(nxt) == 0:
                break
            node = nxt[0].copy()
        var text = self._generate(resolved)
        return ExecutionResult(text, context^, steps^, self._new_id())

    def _new_id(mut self) -> String:
        var current = self.next_id
        self.next_id = current + 1
        return "wf-" + String(current)

    def _generate(self, prompt: String) raises -> String:
        var messages = List[Message]()
        messages.append(Message.user(prompt.copy()))
        return self.llm.generate(messages, GenerationConfig.default())


def _contains(items: List[String], value: String) -> Bool:
    for item in items:
        if item == value:
            return True
    return False
