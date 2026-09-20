from ai_orchestrator.domain.workflow import Graph
from ai_orchestrator.usecase.execute_workflow.command import ExecuteWorkflowCommand
from ai_orchestrator.usecase.execute_workflow.result import ExecuteWorkflowResult
from ai_orchestrator.usecase.generate_response import GenerateCommand, GenerateResponseUseCase
from ai_orchestrator.usecase.retrieve_context import RetrieveContextUseCase, RetrieveQuery


class ExecuteWorkflowUseCase:
    def __init__(self, graph: Graph, generate: GenerateResponseUseCase, retrieve: RetrieveContextUseCase) -> None:
        self._graph = graph
        self._generate = generate
        self._retrieve = retrieve

    def execute(self, command: ExecuteWorkflowCommand) -> ExecuteWorkflowResult:
        steps: list[str] = []
        prompt = command.prompt
        node = self._graph.start()
        visited: set[str] = set()
        while node.id not in visited:
            visited.add(node.id)
            steps.append(node.kind)
            if node.kind == "retrieve":
                hits = self._retrieve.execute(RetrieveQuery(prompt, 3)).texts
                if hits:
                    prompt = "Context:\n" + "\n".join(hits) + "\n\n" + command.prompt
            elif node.kind == "generate":
                text = self._generate.execute(GenerateCommand(prompt)).text
                return ExecuteWorkflowResult(text, steps)
            nxt = self._graph.successors(node.id)
            if not nxt:
                break
            node = nxt[0]
        text = self._generate.execute(GenerateCommand(prompt)).text
        return ExecuteWorkflowResult(text, steps)
