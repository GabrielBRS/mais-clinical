"""Configuração — o resto do sistema recebe um `Settings` já resolvido."""

from __future__ import annotations

from functools import lru_cache
from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_prefix="AOR_",
        env_file=".env",
        extra="ignore",
    )

    app_name: str = "ai-orchestrator-python"
    app_env: Literal["development", "testing", "staging", "production"] = "development"
    log_level: str = "info"

    http_host: str = "0.0.0.0"
    http_port: int = 8080

    grpc_host: str = "0.0.0.0"
    grpc_port: int = 50051

    ipc_path: str = "/tmp/ai-orchestrator-python.sock"
    compute_ipc_path: str = "/tmp/ai-compute-engine.sock"
    data_ipc_path: str = "/tmp/ai-data-engine.sock"

    llm_provider: Literal["local", "openai", "anthropic"] = "local"
    storage_engine: Literal["fjall", "redb"] = "fjall"


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()
