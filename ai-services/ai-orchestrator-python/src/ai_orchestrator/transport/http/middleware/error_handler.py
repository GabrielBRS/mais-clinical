from __future__ import annotations

from collections.abc import Awaitable, Callable

from starlette.requests import Request
from starlette.responses import JSONResponse, Response

from ai_orchestrator.domain.agent import AgentNotFound


async def error_handler_middleware(
    request: Request,
    call_next: Callable[[Request], Awaitable[Response]],
) -> Response:
    try:
        return await call_next(request)
    except AgentNotFound as exc:
        return JSONResponse({"error": "agent_not_found", "id": str(exc)}, status_code=404)
