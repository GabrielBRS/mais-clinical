from __future__ import annotations

from dataclasses import dataclass


@dataclass(slots=True)
class Lineage:
    base: str
    parent: str | None
    method: str
