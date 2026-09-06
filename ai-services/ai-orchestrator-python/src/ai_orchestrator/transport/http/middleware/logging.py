from __future__ import annotations

import logging
from collections.abc import Awaitable, Callable

from starlette.requests import Request
from starlette.responses import Response

_log = logging.getLogger("ai_orchestrator.http")


async def logging_middleware(
    request: Request,
    call_next: Callable[[Request], Awaitable[Response]],
) -> Response:
    response = await call_next(request)
    _log.info("%s %s %s", request.method, request.url.path, response.status_code)
    return response
