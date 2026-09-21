from ai_orchestrator.usecase.retrieve_context.query import RetrieveQuery
from ai_orchestrator.usecase.retrieve_context.result import RetrieveResult


class RetrieveContextUseCase:
    def __init__(self, vector) -> None:
        self._vector = vector

    def execute(self, query: RetrieveQuery) -> RetrieveResult:
        return RetrieveResult(self._vector.search(query.text, query.top_k))
