from host.config import HostSettings
from host.interop.python_runtime import (
    execute_agent,
    execute_workflow,
    health,
    initialize_python,
)
from host.transport.http.request import HTTPRequest
from host.transport.http.response import HTTPResponse
from host.transport.net.tcp import TcpListener


struct AgentRuntimeHost:
    var settings: HostSettings

    def __init__(out self, var settings: HostSettings):
        self.settings = settings^

    def serve(mut self) raises:
        var contracts = initialize_python(self.settings.contract_root)
        var listener = TcpListener(self.settings.host, Int(self.settings.port))
        print(
            "ai-agent-runtime internal http://",
            self.settings.host,
            ":",
            Int(self.settings.port),
            " python=ai_orchestrator",
            " modules=",
            contracts.count,
        )
        while True:
            var connection = listener.accept()
            try:
                var response = self.handle(connection.recv_http())
                connection.send_all(response.encode())
            except error:
                _ = error
                try:
                    connection.send_all(
                        HTTPResponse.json(
                            500,
                            (
                                '{"error":"internal","message":"embedded Python'
                                ' runtime failed"}'
                            ),
                        ).encode()
                    )
                except send_error:
                    _ = send_error
            connection.close()

    def handle(self, raw: String) raises -> HTTPResponse:
        var request = HTTPRequest.parse(raw)
        if request.method == "GET" and (
            request.path == "/health"
            or request.path == "/health/live"
            or request.path == "/health/ready"
        ):
            var result = health()
            return HTTPResponse.json(result.status, result.body)
        if request.method == "POST" and request.path == "/agents/execute":
            var result = execute_agent(request.body)
            return HTTPResponse.json(result.status, result.body)
        if request.method == "POST" and request.path == "/workflows/execute":
            var result = execute_workflow(request.body)
            return HTTPResponse.json(result.status, result.body)
        return HTTPResponse.json(
            404,
            '{"error":"not_found","message":"internal route not found"}',
        )
