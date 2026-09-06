class RustNative:
    def rerank(self, query: str, documents: list[str]) -> list[float]:
        del query
        return [0.0] * len(documents)

    def encode(self, text: str) -> list[int]:
        return list(text.encode())
