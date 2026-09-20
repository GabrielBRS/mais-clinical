from infrastructure.local.vector import InMemoryVector


struct Retriever(Copyable):
    var store: InMemoryVector

    def __init__(out self, var store: InMemoryVector):
        self.store = store^

    def retrieve(self, query: String, k: Int) -> List[String]:
        return self.store.search(query, k)
