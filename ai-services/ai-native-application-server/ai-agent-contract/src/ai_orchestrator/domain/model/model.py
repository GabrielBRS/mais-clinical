from __future__ import annotations

from dataclasses import dataclass

from ai_orchestrator.domain.model.model_id import ModelId
from ai_orchestrator.domain.model.provider import Provider


@dataclass(frozen=True, slots=True)
class Model:
    id: ModelId
    provider: Provider
    name: str
