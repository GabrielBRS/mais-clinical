from application.agents.registry import default_agents
from application.agents.supervisor import Supervisor
from application.graph.executor import GraphExecutor
from application.graph.graph import Graph
from application.tools.registry import ToolRegistry
from domain.execution import ExecutionResult
from domain.status import Status
from infrastructure.ipc.protocol import (
    Frame,
    MessageType,
    payload_from_string,
    payload_to_string,
)
from infrastructure.local.llm import LocalLlm
from infrastructure.local.vector import InMemoryVector
from infrastructure.memory.memory import ConversationMemory

from .config import Settings
from .lifecycle import Lifecycle

comptime VERSION = "0.1.0"


@fieldwise_init
struct Health(Copyable):
    var status: Status
    var version: String
    var ready: Bool


struct Application:
    var settings: Settings
    var lifecycle: Lifecycle
    var supervisor: Supervisor
    var workflows: GraphExecutor
    var memory: ConversationMemory
    var tools: ToolRegistry

    def __init__(
        out self,
        var settings: Settings,
        var supervisor: Supervisor,
        var workflows: GraphExecutor,
        var memory: ConversationMemory,
        var tools: ToolRegistry,
    ):
        self.settings = settings^
        self.lifecycle = Lifecycle()
        self.supervisor = supervisor^
        self.workflows = workflows^
        self.memory = memory^
        self.tools = tools^

    def health(self) -> Health:
        return Health(Status.ok(), VERSION, self.lifecycle.is_running())

    def execute_agent(
        mut self,
        agent_id: String,
        prompt: String,
        retrieve: Bool = False,
        backend: String = "local",
    ) raises -> ExecutionResult:
        return self.supervisor.execute(agent_id, prompt, retrieve, backend)

    def execute_workflow(mut self, prompt: String) raises -> ExecutionResult:
        return self.workflows.execute(prompt)

    def handle(mut self, incoming: Frame) raises -> Frame:
        var rid = incoming.header.request_id
        if incoming.header.type == MessageType.health_request:
            return Frame.new(
                MessageType.health_response, rid, payload_from_string(VERSION)
            )
        if incoming.header.type == MessageType.agent_execute_request:
            var result = self.execute_agent(
                "default", payload_to_string(incoming.payload)
            )
            return Frame.new(
                MessageType.agent_execute_response,
                rid,
                payload_from_string(result.text),
            )
        if incoming.header.type == MessageType.workflow_execute_request:
            var result = self.execute_workflow(
                payload_to_string(incoming.payload)
            )
            return Frame.new(
                MessageType.workflow_execute_response,
                rid,
                payload_from_string(result.text),
            )
        return Frame.new(
            MessageType.error, rid, payload_from_string("unimplemented")
        )

    def run(mut self) raises -> Int:
        self.lifecycle.start()
        var probe = self.execute_agent("default", "hello")
        print(
            "ai-orchestrator",
            VERSION,
            "ready=",
            self.lifecycle.is_running(),
            " provider=",
            self.settings.llm_provider,
            " ipc://",
            self.settings.ipc_path,
            " http://",
            self.settings.http_host,
            ":",
            Int(self.settings.http_port),
        )
        print("self-check", probe.execution_id, probe.text)
        self.lifecycle.stop()
        return 0


def make_application(var settings: Settings) raises -> Application:
    var llm = LocalLlm()
    var vector = InMemoryVector.with_default_corpus()
    var supervisor = Supervisor(default_agents(), llm.copy(), vector.copy())
    var workflows = GraphExecutor(
        Graph.default_retrieve_generate(), llm.copy(), vector.copy()
    )
    return Application(
        settings^, supervisor^, workflows^, ConversationMemory(), ToolRegistry()
    )
