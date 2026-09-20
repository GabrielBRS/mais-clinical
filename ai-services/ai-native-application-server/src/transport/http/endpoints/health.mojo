from application.application import Application, Health
from application.use_cases.get_health import GetHealthUseCase
from transport.http.json import json_escape
from transport.http.request import HTTPRequest
from transport.http.response import HTTPResponse
from transport.http.router import Router


def register_health_endpoints(mut router: Router):
    router.get("/health", "health.live", handle_health_live)
    router.get("/health/live", "health.live", handle_health_live)
    router.get("/health/ready", "health.ready", handle_health_ready)


def _health_body(health: Health) -> String:
    var ready = String("false")
    if health.ready:
        ready = "true"
    return (
        "{\"status\":\"ok\",\"version\":\""
        + json_escape(health.version)
        + "\",\"ready\":"
        + ready
        + "}"
    )


def handle_health_live(
    mut app: Application, request: HTTPRequest
) raises -> HTTPResponse:
    _ = request
    var health = GetHealthUseCase.execute(app)
    return HTTPResponse.json(200, _health_body(health))


def handle_health_ready(
    mut app: Application, request: HTTPRequest
) raises -> HTTPResponse:
    _ = request
    var health = GetHealthUseCase.execute(app)
    if health.ready:
        return HTTPResponse.json(200, _health_body(health))
    return HTTPResponse.json(
        503, "{\"error\":\"unavailable\",\"message\":\"not ready\"}"
    )
