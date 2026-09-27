"""TESTED LOCALLY: real TCP, uvicorn and official MCP client; no inference simulation."""

import os
import socket
import subprocess
import sys
import time
from pathlib import Path

import httpx
import pytest
from mcp import ClientSession

from orzyon.mcp_client import connect


@pytest.fixture
def live_server(tmp_path: Path):
    token = "live-test-token-only-0123456789abcdef"
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        port = sock.getsockname()[1]
    url = f"http://127.0.0.1:{port}"
    env = {
        **os.environ,
        "ORZYON_API_TOKEN": token,
        "ORZYON_MCP_BASE_URL": url,
        "ORZYON_DOCUMENT_ROOT": str(Path("knowledge").resolve()),
        "ORZYON_OTLP_ENDPOINT": "",
        "ORZYON_GATEWAY_TOKEN": "",
    }
    with (tmp_path / "server.log").open("w") as log:
        process = subprocess.Popen(
            [
                sys.executable,
                "-m",
                "uvicorn",
                "orzyon.api:create_app",
                "--factory",
                "--host",
                "127.0.0.1",
                "--port",
                str(port),
                "--no-access-log",
            ],
            env=env,
            stdout=log,
            stderr=log,
        )
        try:
            with httpx.Client(timeout=1, trust_env=False) as client:
                for _ in range(100):
                    if process.poll() is not None:
                        pytest.fail("Server exited; inspect test server log")
                    try:
                        if client.get(url + "/health/ready").status_code == 200:
                            break
                    except httpx.HTTPError:
                        pass
                    time.sleep(0.1)
                else:
                    pytest.fail("Server did not become ready")
            yield url, token
        finally:
            process.terminate()
            process.wait(timeout=10)


async def test_official_sdk_over_tcp(live_server: tuple[str, str]) -> None:
    url, token = live_server
    for name in ("platform", "knowledge", "observability"):
        async with connect(url + f"/mcp/{name}/", headers={"Authorization": f"Bearer {token}"}) as (
            read,
            write,
            _,
        ):
            async with ClientSession(read, write) as session:
                initialized = await session.initialize()
                assert initialized.serverInfo.name == f"{name}-mcp"
                assert (await session.list_tools()).tools
                if name == "knowledge":
                    result = await session.call_tool("search_documents", {"query": "Kubernetes"})
                    assert not result.isError
                    assert "platform.md" in result.model_dump_json()
                if name == "platform":
                    result = await session.call_tool("list_deployments", {})
                    assert result.isError  # No Kubernetes credentials on the host; fail honestly.
