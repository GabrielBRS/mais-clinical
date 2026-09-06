from fastapi.testclient import TestClient

from ai_orchestrator.adapter.llm.local import LocalLlm
from ai_orchestrator.adapter.llm.openai import OpenAiLlm
from ai_orchestrator.adapter.memory.redis import RedisMemory
from ai_orchestrator.adapter.storage.fjall import FjallStorage
from ai_orchestrator.adapter.storage.redb import RedbStorage
from ai_orchestrator.adapter.vector.milvus import MilvusVector
from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.config.settings import Settings
from ai_orchestrator.transport.grpc.server import create_grpc_server
from ai_orchestrator.transport.http import create_http_app


def test_container_wires_settings(container: AppContainer) -> None:
    assert container.settings.app_name == "ai-orchestrator-python"


def test_build_preserves_injected_settings(settings: Settings) -> None:
    container = AppContainer.build(settings)
    assert container.settings.http_port == 0
    assert container.settings.grpc_port == 0


def test_container_wires_default_adapters(container: AppContainer) -> None:
    assert isinstance(container.llm, LocalLlm)
    assert isinstance(container.memory, RedisMemory)
    assert isinstance(container.storage, FjallStorage)
    assert isinstance(container.vector, MilvusVector)


def test_container_selects_openai_llm() -> None:
    container = AppContainer.build(Settings(llm_provider="openai"))
    assert isinstance(container.llm, OpenAiLlm)


def test_container_selects_redb_storage() -> None:
    container = AppContainer.build(Settings(storage_engine="redb"))
    assert isinstance(container.storage, RedbStorage)


def test_http_app_receives_container(container: AppContainer) -> None:
    app = create_http_app(container)
    assert app.state.container is container


def test_http_health_live(container: AppContainer) -> None:
    app = create_http_app(container)
    with TestClient(app) as client:
        response = client.get("/health/live")
        assert response.status_code == 200
        assert response.json() == {"status": "ok"}
        assert "x-request-id" in response.headers


def test_http_health_ready(container: AppContainer) -> None:
    app = create_http_app(container)
    with TestClient(app) as client:
        assert client.get("/health/ready").json() == {"status": "ok"}


def test_http_root(container: AppContainer) -> None:
    app = create_http_app(container)
    with TestClient(app) as client:
        body = client.get("/").json()
        assert body["name"] == "ai-orchestrator-python"
        assert body["health"]["live"] == "/health/live"


def test_http_execute_agent(container: AppContainer) -> None:
    app = create_http_app(container)
    with TestClient(app) as client:
        response = client.post(
            "/agents/execute",
            json={"agent_id": "default", "prompt": "hello"},
        )
        assert response.status_code == 200
        assert response.json()["text"] == "[local] hello"


def test_http_execute_workflow(container: AppContainer) -> None:
    app = create_http_app(container)
    with TestClient(app) as client:
        response = client.post("/workflows/execute", json={"prompt": "ACE1 framing"})
        assert response.status_code == 200
        assert "retrieve" in response.json()["steps"]
        assert "generate" in response.json()["steps"]


def test_grpc_server_binds_from_container(container: AppContainer) -> None:
    assert create_grpc_server(container) is not None
