from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class GenerationConfig:
    max_tokens: int = 256
    temperature: float = 0.7
    top_p: float = 1.0
