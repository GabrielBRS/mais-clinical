from application.application import Application as Orchestrator
from application.application import make_application
from application.config import Settings
from infrastructure.settings import load_settings
from transport.http.endpoints.agent import register_agent_endpoints
from transport.http.endpoints.health import register_health_endpoints
from transport.http.endpoints.workflow import register_workflow_endpoints
from transport.http.router import Router
from transport.http.server import HTTPServer
from transport.ipc.server import IPCServer
from transport.server import Service


struct Application:
    """Process composition root. Wires use cases to input adapters."""

    var orchestrator: Orchestrator
    var service: Service
    var settings: Settings

    def __init__(
        out self,
        var orchestrator: Orchestrator,
        var service: Service,
        var settings: Settings,
    ):
        self.orchestrator = orchestrator^
        self.service = service^
        self.settings = settings^

    @staticmethod
    def build() raises -> Application:
        var settings = load_settings()
        var orchestrator = make_application(settings.copy())
        var router = Router()
        register_health_endpoints(router)
        register_agent_endpoints(router)
        register_workflow_endpoints(router)
        var http = HTTPServer(
            router^, settings.http_host.copy(), settings.http_port
        )
        var ipc = IPCServer(settings.ipc_path.copy())
        return Application(orchestrator^, Service(http^, ipc^), settings^)

    def run(mut self) raises:
        self.orchestrator.lifecycle.start()
        print(
            "ai-agent-engine internal",
            self.orchestrator.health().version,
            "http://",
            self.settings.http_host,
            ":",
            Int(self.settings.http_port),
        )
        self.service.serve(self.orchestrator)
