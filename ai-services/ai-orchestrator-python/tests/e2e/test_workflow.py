from fastapi.testclient import TestClient

from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.transport.http import create_http_app


def test_workflow_retrieve_then_generate() -> None:
    container = AppContainer.build()
    app = create_http_app(container)
    with TestClient(app) as client:
        body = client.post("/workflows/execute", json={"prompt": "orchestrator"}).json()
        assert body["steps"] == ["retrieve", "generate"]
        assert "[local]" in body["text"]
