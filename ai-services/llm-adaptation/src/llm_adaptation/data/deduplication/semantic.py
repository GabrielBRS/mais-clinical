from __future__ import annotations


def _embed(text: str, dim: int = 32) -> list[float]:
    values = [0.0] * dim
    for token in text.lower().split():
        h = 1469598103934665603
        for byte in token.encode():
            h ^= byte
            h = (h * 1099511628211) & 0xFFFFFFFFFFFFFFFF
        values[h % dim] += 1.0
    norm = sum(v * v for v in values) ** 0.5
    return [v / norm for v in values] if norm else values


def _cosine(a: list[float], b: list[float]) -> float:
    return sum(x * y for x, y in zip(a, b, strict=True))


def semantic_hits(query: str, corpus: list[str], *, threshold: float = 0.92) -> list[int]:
    q = _embed(query)
    return [i for i, text in enumerate(corpus) if _cosine(q, _embed(text)) >= threshold]
