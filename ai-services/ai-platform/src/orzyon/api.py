import hmac
import logging
from contextlib import AsyncExitStack, asynccontextmanager
from typing import Any

import httpx
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse, Response
from opentelemetry import context, propagate, trace
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest
from pydantic import BaseModel, Field

from orzyon import __version__, agent
from orzyon.backends import BackendUnavailable
from orzyon.config import Settings
from orzyon.knowledge import Knowledge
from orzyon.mcp_servers import create_servers
from orzyon.telemetry import Telemetry


class Question(BaseModel):
    question: str = Field(min_length=1, max_length=500)


def create_app(settings: Settings | None = None) -> FastAPI:
    settings = settings or Settings()  # type: ignore[call-arg]
    knowledge = Knowledge(settings.document_root)
    telemetry = Telemetry()
    servers = create_servers(settings, knowledge, telemetry)

    @asynccontextmanager
    async def lifespan(app: FastAPI):  # type: ignore[no-untyped-def]
        provider = None
        if settings.otlp_endpoint:
            from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
            from opentelemetry.sdk.resources import Resource
            from opentelemetry.sdk.trace import TracerProvider
            from opentelemetry.sdk.trace.export import BatchSpanProcessor

            provider = TracerProvider(resource=Resource.create({"service.name": "orzyon"}))
            provider.add_span_processor(
                BatchSpanProcessor(
                    OTLPSpanExporter(endpoint=settings.otlp_endpoint + "/v1/traces", timeout=3)
                )
            )
            trace.set_tracer_provider(provider)
        async with AsyncExitStack() as stack:
            for server in servers.values():
                await stack.enter_async_context(server.session_manager.run())
            app.state.ready = True
            try:
                yield
            finally:
                app.state.ready = False
        if provider:
            provider.shutdown()

    app = FastAPI(title="Orzyon AI Platform", version=__version__, lifespan=lifespan)
    app.state.ready = False

    @app.middleware("http")
    async def protect(request: Request, call_next: Any) -> Response:
        public = {"/", "/health/live", "/health/ready", "/metrics"}
        if request.url.path not in public:
            supplied = request.headers.get("Authorization", "")
            expected = "Bearer " + settings.api_token.get_secret_value()
            if not hmac.compare_digest(supplied.encode(), expected.encode()):
                telemetry.requests.labels("401").inc()
                logging.getLogger("orzyon.audit").info('{"event":"auth","result":"denied"}')
                return JSONResponse(
                    {"detail": "Unauthorized"},
                    status_code=401,
                    headers={"WWW-Authenticate": "Bearer"},
                )
        token = context.attach(propagate.extract(dict(request.headers)))
        try:
            with telemetry.tracer.start_as_current_span("http.request"):
                response = await call_next(request)
                telemetry.requests.labels(str(response.status_code)).inc()
                response.headers["X-Content-Type-Options"] = "nosniff"
                response.headers["Cache-Control"] = "no-store"
                return response
        finally:
            context.detach(token)

    @app.get("/health/live")
    async def live() -> dict[str, str]:
        return {"status": "alive", "version": __version__}

    @app.get("/health/ready")
    async def ready() -> Response:
        return JSONResponse({"ready": app.state.ready}, status_code=200 if app.state.ready else 503)

    @app.get("/metrics")
    async def metrics() -> Response:
        return Response(
            generate_latest(telemetry.registry), headers={"Content-Type": CONTENT_TYPE_LATEST}
        )

    @app.get("/api/v1/documents")
    async def search(q: str, limit: int = 5) -> Any:
        try:
            return knowledge.search(q, limit)
        except ValueError as error:
            return JSONResponse({"detail": str(error)}, status_code=422)

    @app.post("/api/v1/agent")
    async def run_agent(question: Question) -> Any:
        try:
            return await agent.answer(settings, question.question)
        except (BackendUnavailable, httpx.HTTPError, TimeoutError, ExceptionGroup):
            return JSONResponse({"detail": "Dependency unavailable or timed out"}, status_code=503)

    @app.get("/", response_class=HTMLResponse)
    async def home() -> str:
        from importlib.resources import files

        return files("orzyon").joinpath("web.html").read_text(encoding="utf-8")

    for name, server in servers.items():
        app.mount(f"/mcp/{name}", server.streamable_http_app())
    return app
