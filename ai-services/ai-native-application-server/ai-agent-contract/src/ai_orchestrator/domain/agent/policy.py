from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class Policy:
    max_tokens: int = 512
    allow_tools: bool = True
    allow_retrieval: bool = True
