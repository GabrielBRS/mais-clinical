from fastapi import FastAPI

from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.transport.http.middleware import (
    error_handler_middleware,
    logging_middleware,
    request_id_middleware,
    tracing_middleware,
)
from ai_orchestrator.transport.http.router import api_router


def create_http_app(container: AppContainer) -> FastAPI:
    app = FastAPI(title=container.settings.app_name)
    app.state.container = container
    app.middleware("http")(error_handler_middleware)
    app.middleware("http")(tracing_middleware)
    app.middleware("http")(logging_middleware)
    app.middleware("http")(request_id_middleware)
    app.include_router(api_router)

    @app.get("/")
    async def root() -> dict:
        return {
            "name": container.settings.app_name,
            "status": "ok",
            "health": {"live": "/health/live", "ready": "/health/ready"},
            "ipc": container.settings.ipc_path,
        }

    return app
