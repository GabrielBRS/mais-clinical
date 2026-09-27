import httpx
import pytest

from orzyon.backends import BackendUnavailable, get_json


@pytest.mark.parametrize(
    "response",
    [
        httpx.Response(503),
        httpx.Response(200, json=[]),
        httpx.Response(200, text="not json"),
        httpx.Response(200, content=b"x" * 1_000_001),
    ],
)
async def test_dependency_failures(
    monkeypatch: pytest.MonkeyPatch, response: httpx.Response
) -> None:
    real_client = httpx.AsyncClient
    monkeypatch.setattr(
        httpx,
        "AsyncClient",
        lambda **kw: real_client(transport=httpx.MockTransport(lambda request: response)),
    )
    with pytest.raises(BackendUnavailable):
        await get_json("http://dependency.invalid")


async def test_dependency_response(monkeypatch: pytest.MonkeyPatch) -> None:
    real_client = httpx.AsyncClient
    monkeypatch.setattr(
        httpx,
        "AsyncClient",
        lambda **kw: real_client(
            transport=httpx.MockTransport(
                lambda request: httpx.Response(200, json={"status": "success"})
            )
        ),
    )
    assert await get_json("http://dependency.invalid") == {"status": "success"}


async def test_dependency_timeout(monkeypatch: pytest.MonkeyPatch) -> None:
    def timeout(request: httpx.Request) -> httpx.Response:
        raise httpx.ReadTimeout("synthetic timeout", request=request)

    real_client = httpx.AsyncClient
    monkeypatch.setattr(
        httpx, "AsyncClient", lambda **kw: real_client(transport=httpx.MockTransport(timeout))
    )
    with pytest.raises(BackendUnavailable, match="Dependency request failed"):
        await get_json("http://dependency.invalid")
