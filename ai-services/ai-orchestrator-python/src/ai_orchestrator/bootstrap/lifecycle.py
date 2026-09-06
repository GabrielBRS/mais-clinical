from __future__ import annotations

import asyncio
import logging

import uvicorn

_log = logging.getLogger("ai_orchestrator.lifecycle")


async def shutdown(
    uvicorn_server: uvicorn.Server | None,
    grpc_server,
    *tasks: asyncio.Task,
) -> None:
    _log.info("shutdown")
    if uvicorn_server is not None:
        uvicorn_server.should_exit = True
    await grpc_server.stop(grace=5)
    await asyncio.gather(*tasks, return_exceptions=True)
