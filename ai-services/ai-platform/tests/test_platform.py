import json
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from pydantic import SecretStr, ValidationError

from orzyon.api import create_app
from orzyon.config import Settings
from orzyon.knowledge import Knowledge

TOKEN = "test-only-not-a-real-secret-0123456789"
AUTH = {"Authorization": f"Bearer {TOKEN}"}


@pytest.fixture
def settings(tmp_path: Path) -> Settings:
    (tmp_path / "guide.md").write_text("# Kubernetes\nGPU scheduling and Pending pods.")
    return Settings(api_token=SecretStr(TOKEN), document_root=tmp_path, _env_file=None)


def test_config_fails_closed() -> None:
    with pytest.raises(ValidationError):
        Settings(api_token=SecretStr("short"), _env_file=None)
    with pytest.raises(ValidationError):
        Settings(api_token=SecretStr(TOKEN), gateway_url="file:///etc/passwd", _env_file=None)
    with pytest.raises(ValidationError):
        Settings(api_token=SecretStr(TOKEN), gateway_url="", _env_file=None)


def test_corpus_limits_and_path_injection(settings: Settings) -> None:
    corpus = Knowledge(settings.document_root)
    hit = corpus.search("GPU")[0]
    assert corpus.retrieve(str(hit["id"]))["source"] == "guide.md"
    assert corpus.search("nonexistent") == []
    for invalid in ("../guide.md", "file:///etc/passwd", "guide.md"):
        with pytest.raises(ValueError):
            corpus.retrieve(invalid)
    with pytest.raises(ValueError):
        corpus.search("GPU", 100)
    (settings.document_root / "large.md").write_text("x" * 100_001)
    with pytest.raises(ValueError):
        Knowledge(settings.document_root)


def test_health_auth_and_retrieval(settings: Settings) -> None:
    with TestClient(create_app(settings)) as client:
        assert client.get("/health/ready").status_code == 200
        assert client.get("/").status_code == 200
        assert client.get("/api/v1/documents?q=GPU").status_code == 401
        assert client.get("/docs").status_code == 401
        result = client.get("/api/v1/documents?q=GPU", headers=AUTH)
        assert result.json()[0]["source"] == "guide.md"
        assert client.get("/api/v1/documents?q=GPU&limit=99", headers=AUTH).status_code == 422
        assert (
            client.post("/api/v1/agent", headers=AUTH, json={"question": "GPU"}).status_code == 503
        )
        assert 'orzyon_http_requests_total{status="401"}' in client.get("/metrics").text
        assert TOKEN not in client.get("/metrics").text


def rpc(
    client: TestClient, service: str, method: str, params: dict | None = None, request_id: int = 1
) -> dict:
    response = client.post(
        f"/mcp/{service}/",
        headers={
            **AUTH,
            "Accept": "application/json, text/event-stream",
            "MCP-Protocol-Version": "2025-11-25",
        },
        json={"jsonrpc": "2.0", "id": request_id, "method": method, "params": params or {}},
    )
    assert response.status_code == 200, response.text
    return response.json()


@pytest.mark.parametrize(
    "service,tool",
    [
        ("platform", "list_deployments"),
        ("knowledge", "search_documents"),
        ("observability", "query_metrics"),
    ],
)
def test_real_mcp_protocol(settings: Settings, service: str, tool: str) -> None:
    with TestClient(create_app(settings)) as client:
        assert client.post(f"/mcp/{service}/", json={}).status_code == 401
        initialized = rpc(
            client,
            service,
            "initialize",
            {
                "protocolVersion": "2025-11-25",
                "capabilities": {},
                "clientInfo": {"name": "contract-test", "version": "1.0"},
            },
        )
        assert initialized["result"]["serverInfo"]["name"] == f"{service}-mcp"
        listed = rpc(client, service, "tools/list")
        assert tool in {item["name"] for item in listed["result"]["tools"]}
        denied = rpc(client, service, "tools/call", {"name": "delete_namespace", "arguments": {}})
        assert denied["result"]["isError"] is True


def test_mcp_search_error_and_telemetry(settings: Settings) -> None:
    with TestClient(create_app(settings)) as client:
        found = rpc(
            client,
            "knowledge",
            "tools/call",
            {"name": "search_documents", "arguments": {"query": "GPU"}},
        )
        assert not found["result"]["isError"]
        assert "guide.md" in json.dumps(found)
        bad = rpc(
            client,
            "knowledge",
            "tools/call",
            {"name": "retrieve_document", "arguments": {"document_id": "../.env"}},
        )
        assert bad["result"]["isError"]
        assert 'outcome="error",tool="retrieve_document"' in client.get("/metrics").text


def test_promql_allowlist(settings: Settings) -> None:
    with TestClient(create_app(settings)) as client:
        bad = rpc(
            client,
            "observability",
            "tools/call",
            {"name": "query_metrics", "arguments": {"query_name": "http://evil.invalid"}},
        )
        assert bad["result"]["isError"]
