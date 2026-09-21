from __future__ import annotations

from dataclasses import dataclass


@dataclass(slots=True)
class RuntimeContext:
    request_id: str
    cancelled: bool = False
