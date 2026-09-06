from __future__ import annotations

from enum import Enum


class Provider(str, Enum):
    LOCAL = "local"
    OPENAI = "openai"
    ANTHROPIC = "anthropic"
    COMPUTE_ENGINE = "compute_engine"
