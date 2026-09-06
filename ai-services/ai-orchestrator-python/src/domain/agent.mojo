from .errors import OrchestratorError, agent_not_found


@fieldwise_init
struct Capability(Equatable, ImplicitlyCopyable, Writable):
    var _value: Int

    comptime generate = Self(0)
    comptime retrieve = Self(1)
    comptime tool = Self(2)
    comptime workflow = Self(3)

    def name(self) -> String:
        if self == Self.generate:
            return "generate"
        if self == Self.retrieve:
            return "retrieve"
        if self == Self.tool:
            return "tool"
        if self == Self.workflow:
            return "workflow"
        return "unknown"

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.name())


@fieldwise_init
struct Policy(Copyable, ImplicitlyCopyable):
    var max_tokens: Int
    var allow_tools: Bool
    var allow_retrieval: Bool

    @staticmethod
    def default() -> Self:
        return Self(512, True, True)


struct Agent(Copyable):
    var id: String
    var name: String
    var capabilities: List[Capability]
    var policy: Policy
    var system_prompt: String

    def __init__(
        out self,
        var id: String,
        var name: String,
        var capabilities: List[Capability] = List[Capability](),
        policy: Policy = Policy.default(),
        var system_prompt: String = "You are a helpful orchestrator agent.",
    ):
        self.id = id^
        self.name = name^
        self.capabilities = capabilities^
        self.policy = policy
        self.system_prompt = system_prompt^


struct AgentRegistry(Copyable):
    var agents: List[Agent]

    def __init__(out self, var agents: List[Agent] = List[Agent]()):
        self.agents = agents^

    def add(mut self, var agent: Agent):
        self.agents.append(agent^)

    def get(self, agent_id: String) raises OrchestratorError -> Agent:
        for agent in self.agents:
            if agent.id == agent_id:
                return agent.copy()
        raise agent_not_found(agent_id)

    def ids(self) -> List[String]:
        var out = List[String]()
        for agent in self.agents:
            out.append(agent.id.copy())
        return out^

    @staticmethod
    def default_agent() -> Agent:
        var capabilities = List[Capability]()
        capabilities.append(Capability.generate)
        capabilities.append(Capability.retrieve)
        return Agent("default", "default", capabilities^)
