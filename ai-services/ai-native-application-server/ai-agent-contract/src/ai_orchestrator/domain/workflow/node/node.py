from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class Node:
    id: str
    kind: str  # generate | retrieve | tool
    label: str = ""
