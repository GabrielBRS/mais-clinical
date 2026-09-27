from __future__ import annotations

import pytest

from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.config.settings import Settings


@pytest.fixture
def settings() -> Settings:
    return Settings(app_env="development", http_port=0, grpc_port=0)


@pytest.fixture
def container(settings: Settings) -> AppContainer:
    return AppContainer.build(settings)
