from pathlib import Path
from typing import Literal

from pydantic import Field, SecretStr, ValidationInfo, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="ORZYON_", env_file=".env", extra="ignore")
    environment: Literal["local", "dev"] = "local"
    api_token: SecretStr
    document_root: Path = Path("knowledge")
    namespace: str = Field(default="orzyon", pattern=r"^[a-z0-9]([-a-z0-9]*[a-z0-9])?$")
    prometheus_url: str = "http://127.0.0.1:9090"
    gateway_url: str = "http://127.0.0.1:4000"
    gateway_token: SecretStr = SecretStr("")
    model: str = "local-model"
    mcp_base_url: str = "http://127.0.0.1:8000"
    otlp_endpoint: str = ""
    request_timeout: float = Field(default=20, ge=1, le=120)
    max_output_tokens: int = Field(default=512, ge=1, le=2048)

    @field_validator("api_token")
    @classmethod
    def strong_token(cls, value: SecretStr) -> SecretStr:
        if len(value.get_secret_value()) < 32:
            raise ValueError("ORZYON_API_TOKEN must contain at least 32 characters")
        return value

    @field_validator("prometheus_url", "gateway_url", "mcp_base_url", "otlp_endpoint")
    @classmethod
    def valid_url(cls, value: str, info: ValidationInfo) -> str:
        from urllib.parse import urlsplit

        if not value:
            if info.field_name == "otlp_endpoint":
                return value
            raise ValueError("Service URL cannot be empty")
        url = urlsplit(value)
        if url.scheme not in {"http", "https"} or not url.hostname or url.username:
            raise ValueError("Expected an HTTP(S) service URL without embedded credentials")
        if url.query or url.fragment:
            raise ValueError("Service URLs cannot contain query strings or fragments")
        return value.rstrip("/")
