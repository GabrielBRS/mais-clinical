from __future__ import annotations

from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True, slots=True)
class ExecuteToolCommand:
    name: str
    arguments: dict[str, Any]
