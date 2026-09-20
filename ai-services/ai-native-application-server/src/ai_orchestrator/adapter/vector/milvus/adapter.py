from __future__ import annotations

from ai_orchestrator.adapter.llm.local.adapter import _hash_embed


class MilvusVector:
    """Índice em memória. Troca pelo client Milvus sem mudar o port."""

    def __init__(self) -> None:
        self._texts: list[str] = []

    def index(self, texts: list[str]) -> int:
        self._texts.extend(texts)
        return len(texts)

    def search(self, query: str, top_k: int = 8) -> list[str]:
        q = _hash_embed(query)
        scored = []
        for text in self._texts:
            e = _hash_embed(text)
            score = sum(a * b for a, b in zip(q, e, strict=True))
            scored.append((score, text))
        scored.sort(key=lambda x: x[0], reverse=True)
        return [t for _, t in scored[: max(1, top_k)]]
