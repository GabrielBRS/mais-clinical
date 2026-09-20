from infrastructure.compute.kernels import hash_embed


struct EmbeddingModel(Copyable):
    """Local hash embeddings. Same kernel as InMemoryVector."""

    var _marker: Bool

    def __init__(out self):
        self._marker = True

    def ping(self) -> String:
        return "{\"backend\":\"hash_embed\",\"owner\":\"mojo\"}"

    def embed_batch(self, texts: List[String]) -> List[List[Float64]]:
        var out = List[List[Float64]]()
        for text in texts:
            out.append(hash_embed(text))
        return out^
