from infrastructure.local.vector import InMemoryVector

from .reranker import rerank
from .retriever import Retriever


struct RagPipeline(Copyable):
    var retriever: Retriever

    def __init__(out self, var store: InMemoryVector):
        self.retriever = Retriever(store^)

    def retrieve(self, query: String, k: Int = 4) -> List[String]:
        var hits = self.retriever.retrieve(query, k)
        return rerank(query, hits, k)


def prefix_context(hits: List[String], prompt: String) -> String:
    var out = String("Context:\n")
    var first = True
    for hit in hits:
        if not first:
            out += "\n"
        first = False
        out += hit
    out += "\n\n"
    out += prompt
    return out^
