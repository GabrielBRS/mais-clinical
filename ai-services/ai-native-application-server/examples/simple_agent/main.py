from fastapi.testclient import TestClient

from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.transport.http import create_http_app


def main() -> None:
    client = TestClient(create_http_app(AppContainer.build()))
    print(client.post("/agents/execute", json={"prompt": "hello agent"}).json())


if __name__ == "__main__":
    main()
