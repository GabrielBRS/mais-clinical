from fastapi.testclient import TestClient

from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.transport.http import create_http_app


def test_live_and_ready() -> None:
    client = TestClient(create_http_app(AppContainer.build()))
    assert client.get("/health/live").json() == {"status": "ok"}
    assert client.get("/health/ready").json() == {"status": "ok"}
