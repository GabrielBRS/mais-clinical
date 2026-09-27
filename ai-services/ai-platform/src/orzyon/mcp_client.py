from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from typing import Any

import httpx
from mcp.client.streamable_http import streamable_http_client


@asynccontextmanager
async def connect(url: str, headers: dict[str, str]) -> AsyncIterator[tuple[Any, Any, Any]]:
    """Official SDK transport with explicit timeout and no inherited proxy credentials."""
    async with httpx.AsyncClient(headers=headers, timeout=20, trust_env=False) as client:
        async with streamable_http_client(url, http_client=client) as streams:
            yield streams
