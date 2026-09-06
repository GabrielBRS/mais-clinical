from compute.kernels import hash_embed
from compute.similarity import dot
from compute.topk import ScoredText, top_k


struct InMemoryVector(Copyable):
    """In-process index. Same contract as the former Python Milvus stub."""

    var texts: List[String]

    def __init__(out self, var texts: List[String] = List[String]()):
        self.texts = texts^

    def index(mut self, var documents: List[String]) -> Int:
        var added = len(documents)
        for text in documents:
            self.texts.append(text.copy())
        return added

    def search(self, query: String, k: Int = 8) -> List[String]:
        var q = hash_embed(query)
        var scored = List[ScoredText]()
        for text in self.texts:
            var score = dot(q, hash_embed(text))
            scored.append(ScoredText(score, text.copy()))
        return top_k(scored, k)

    @staticmethod
    def with_default_corpus() -> InMemoryVector:
        var store = InMemoryVector()
        var docs = List[String]()
        docs.append("ACE1 is the IPC framing used by the three engines.")
        docs.append("The orchestrator routes agents, workflows and tools.")
        _ = store.index(docs^)
        return store^
