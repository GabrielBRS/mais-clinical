from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


@dataclass(slots=True)
class ModelMeta:
    name: str
    version: str
    family: str
    method: str
    extra: dict[str, Any] = field(default_factory=dict)
