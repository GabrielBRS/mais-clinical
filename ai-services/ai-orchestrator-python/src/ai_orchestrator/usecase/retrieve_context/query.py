from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class RetrieveQuery:
    text: str
    top_k: int = 8
