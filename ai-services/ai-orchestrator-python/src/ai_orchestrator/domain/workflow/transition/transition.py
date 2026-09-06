from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class Transition:
    from_node: str
    to_node: str
    condition: str = ""
