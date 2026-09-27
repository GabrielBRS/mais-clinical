from fastapi.testclient import TestClient

from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.transport.http import create_http_app


def test_agent_with_retrieval() -> None:
    container = AppContainer.build()
    app = create_http_app(container)
    with TestClient(app) as client:
        response = client.post(
            "/agents/execute",
            json={"agent_id": "default", "prompt": "what is ACE1", "retrieve": True},
        )
        assert response.status_code == 200
        body = response.json()
        assert body["text"].startswith("[local]")
        assert body["context"]
