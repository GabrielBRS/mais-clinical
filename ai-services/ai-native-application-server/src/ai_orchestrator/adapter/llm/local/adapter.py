from __future__ import annotations

from collections.abc import Iterator

from ai_orchestrator.domain.message import Message
from ai_orchestrator.domain.model import GenerationConfig


class LocalLlm:
    """LLM local — resposta determinística sem vendor. Satisfaz Generate/Stream/Embed."""

    def generate(self, messages: list[Message], config: GenerationConfig) -> str:
        del config
        last = messages[-1].content.text if messages else ""
        return f"[local] {last}"

    def stream(self, messages: list[Message], config: GenerationConfig) -> Iterator[str]:
        yield self.generate(messages, config)

    def embed(self, texts: list[str]) -> list[list[float]]:
        return [_hash_embed(t) for t in texts]


def _hash_embed(text: str, dim: int = 32) -> list[float]:
    values = [0.0] * dim
    for token in text.lower().split():
        h = 1469598103934665603
        for b in token.encode():
            h ^= b
            h = (h * 1099511628211) & 0xFFFFFFFFFFFFFFFF
        values[h % dim] += 1.0
    norm = sum(v * v for v in values) ** 0.5
    if norm:
        values = [v / norm for v in values]
    return values
