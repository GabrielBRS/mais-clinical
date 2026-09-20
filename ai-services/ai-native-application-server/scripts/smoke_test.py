#!/usr/bin/env python3
from fastapi.testclient import TestClient

from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.transport.http import create_http_app


def main() -> None:
    app = create_http_app(AppContainer.build())
    with TestClient(app) as client:
        assert client.get("/health/live").status_code == 200
        body = client.post("/agents/execute", json={"prompt": "ping"}).json()
        print(body["text"])


if __name__ == "__main__":
    main()
