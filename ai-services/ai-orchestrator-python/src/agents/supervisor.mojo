from adapters.local.llm import LocalLlm
from adapters.local.vector import InMemoryVector
from domain.agent import AgentRegistry
from domain.execution import ExecutionResult
from domain.message import Message
from domain.model import GenerationConfig
from graph.router import Router
from rag.pipeline import prefix_context


struct Supervisor(Copyable):
    var agents: AgentRegistry
    var router: Router
    var llm: LocalLlm
    var vector: InMemoryVector
    var next_id: Int

    def __init__(
        out self,
        var agents: AgentRegistry,
        var llm: LocalLlm,
        var vector: InMemoryVector,
    ):
        self.agents = agents^
        self.router = Router()
        self.llm = llm^
        self.vector = vector^
        self.next_id = 1

    def execute(
        mut self, agent_id: String, prompt: String, retrieve: Bool = False
    ) raises -> ExecutionResult:
        var chosen = agent_id
        if chosen.byte_length() == 0:
            chosen = self.router.route("", prompt, self.agents.ids())
        var agent = self.agents.get(chosen)
        var context = List[String]()
        var resolved = prompt.copy()
        if retrieve and agent.policy.allow_retrieval:
            context = self.vector.search(prompt, 4)
            if len(context) > 0:
                resolved = prefix_context(context, prompt)
        var messages = List[Message]()
        messages.append(Message.system(agent.system_prompt.copy()))
        messages.append(Message.user(resolved^))
        var text = self.llm.generate(
            messages, GenerationConfig.with_max_tokens(agent.policy.max_tokens)
        )
        var execution_id = self._new_id()
        return ExecutionResult(text, context^, List[String](), execution_id^)

    def _new_id(mut self) -> String:
        var current = self.next_id
        self.next_id = current + 1
        return "exe-" + String(current)
