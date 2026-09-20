from application.application import Application
from transport.http.request import HTTPRequest
from transport.http.response import HTTPResponse

comptime HTTPHandler = def (
    mut Application, HTTPRequest
) raises thin -> HTTPResponse


@fieldwise_init
struct Endpoint(Copyable):
    """HTTP driving adapter. Owns the handler that calls a use case."""

    var method: String
    var path: String
    var name: String
    var handler: HTTPHandler

    def handle(
        self, mut app: Application, request: HTTPRequest
    ) raises -> HTTPResponse:
        return self.handler(app, request)
