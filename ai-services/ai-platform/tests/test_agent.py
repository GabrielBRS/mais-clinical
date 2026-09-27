"""TESTED WITH MOCK: workflow contract only, not model quality or real inference."""

from contextlib import asynccontextmanager
from pathlib import Path
from types import SimpleNamespace

import httpx
import pytest
from pydantic import SecretStr

from orzyon import agent
from orzyon.backends import BackendUnavailable
from orzyon.config import Settings


@pytest.mark.parametrize(
    "payload,expected_error",
    [
        (
            {
                "choices": [{"message": {"content": "test fixture answer"}}],
                "usage": {"total_tokens": 3},
            },
            False,
        ),
        ({"choices": []}, True),
        ([], True),
    ],
)
async def test_bounded_workflow_contract(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path, payload: dict | list, expected_error: bool
) -> None:
    settings = Settings(
        api_token=SecretStr("x" * 32),
        gateway_token=SecretStr("y" * 32),
        document_root=tmp_path,
        _env_file=None,
    )
    calls = []

    @asynccontextmanager
    async def fake_connect(*args, **kwargs):
        yield None, None, None

    class Session:
        def __init__(self, *args):
            pass

        async def __aenter__(self):
            return self

        async def __aexit__(self, *args):
            pass

        async def initialize(self):
            pass

        async def call_tool(self, name, arguments):
            calls.append((name, arguments))
            return SimpleNamespace(isError=False, model_dump=lambda **kw: {"content": "fixture"})

    requests = []

    def gateway(request: httpx.Request) -> httpx.Response:
        import json

        requests.append(json.loads(request.content))
        return httpx.Response(200, json=payload)

    real_client = httpx.AsyncClient
    monkeypatch.setattr(agent, "connect", fake_connect)
    monkeypatch.setattr(agent, "ClientSession", Session)
    monkeypatch.setattr(
        httpx, "AsyncClient", lambda **kw: real_client(transport=httpx.MockTransport(gateway))
    )
    if expected_error:
        with pytest.raises(BackendUnavailable):
            await agent.answer(settings, "GPU")
    else:
        result = await agent.answer(settings, "GPU")
        assert result["workflow"] == "retrieve-then-generate-v1"
    assert calls == [("search_documents", {"query": "GPU", "limit": 3})]
    assert len(requests) == 1
    assert requests[0]["max_tokens"] == settings.max_output_tokens
