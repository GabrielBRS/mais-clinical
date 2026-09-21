from __future__ import annotations

from contextlib import contextmanager
import json
import os
from pathlib import Path
import socket
import subprocess
import time
from typing import Iterator
from urllib.error import URLError
from urllib.request import Request, urlopen

import pytest


PROJECT = Path(__file__).resolve().parents[3]
MOJO_BINARY = PROJECT / "build/agentd"
RUST_BINARY = PROJECT / "target/debug/ai-native-runtime"


def free_port() -> int:
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", 0))
        return int(listener.getsockname()[1])


def get_json(url: str) -> dict:
    with urlopen(url, timeout=1) as response:  # noqa: S310 - loopback test server
        return json.loads(response.read())


def post_json(url: str, payload: dict) -> dict:
    request = Request(
        url,
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urlopen(request, timeout=2) as response:  # noqa: S310 - loopback test server
        return json.loads(response.read())


def wait_ready(url: str, process: subprocess.Popen[str]) -> None:
    deadline = time.monotonic() + 10
    while time.monotonic() < deadline:
        if process.poll() is not None:
            stdout, stderr = process.communicate()
            raise AssertionError(f"process exited early\nstdout={stdout}\nstderr={stderr}")
        try:
            if get_json(url).get("ready") is True:
                return
        except (OSError, URLError, TimeoutError):
            time.sleep(0.05)
    raise AssertionError(f"process did not become ready: {url}")


@contextmanager
def running(binary: Path, environment: dict[str, str]) -> Iterator[subprocess.Popen[str]]:
    process = subprocess.Popen(  # noqa: S603 - repository-built binaries
        [str(binary)],
        cwd=PROJECT,
        env=environment,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    try:
        yield process
    finally:
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait(timeout=5)


@pytest.mark.skipif(
    not MOJO_BINARY.exists() or not RUST_BINARY.exists(),
    reason="build the Rust application server and Mojo host first",
)
def test_rust_mojo_embedded_python_flow() -> None:
    mojo_port = free_port()
    rust_port = free_port()
    prefix = Path(
        os.environ.get(
            "CONDA_PREFIX", PROJECT / "ai-agent-runtime/.pixi/envs/default"
        )
    )

    mojo_environment = os.environ.copy()
    mojo_environment.update(
        {
            "AOR_AGENT_HTTP_HOST": "127.0.0.1",
            "AOR_AGENT_HTTP_PORT": str(mojo_port),
            "AOR_CONTRACT_ROOT": str(PROJECT / "ai-agent-contract"),
            "MOJO_PYTHON": str(prefix / "bin/python"),
            "MOJO_PYTHON_LIBRARY": str(prefix / "lib/libpython3.13.so"),
        }
    )
    with running(MOJO_BINARY, mojo_environment) as mojo:
        wait_ready(f"http://127.0.0.1:{mojo_port}/health/ready", mojo)

        rust_environment = os.environ.copy()
        rust_environment.update(
            {
                "AOR_HTTP_HOST": "127.0.0.1",
                "AOR_HTTP_PORT": str(rust_port),
                "AOR_AGENT_RUNTIME_URL": f"http://127.0.0.1:{mojo_port}",
            }
        )
        with running(RUST_BINARY, rust_environment) as rust:
            wait_ready(f"http://127.0.0.1:{rust_port}/health/ready", rust)
            response = post_json(
                f"http://127.0.0.1:{rust_port}/agents/execute",
                {"agent_id": "default", "prompt": "hello through all runtimes"},
            )

    assert response["text"] == "[local] hello through all runtimes"
    assert response["steps"] == ["python:ExecuteAgentUseCase"]
