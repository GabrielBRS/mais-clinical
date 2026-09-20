from ai_orchestrator.adapter.llm.anthropic import AnthropicLlm
from ai_orchestrator.adapter.llm.local import LocalLlm
from ai_orchestrator.adapter.llm.openai import OpenAiLlm
from ai_orchestrator.adapter.storage.fjall import FjallStorage
from ai_orchestrator.adapter.storage.redb import RedbStorage
from ai_orchestrator.config.settings import Settings
from ai_orchestrator.domain.agent import Agent, AgentId, Capability
from ai_orchestrator.domain.workflow import Edge, Graph, Node


def llm(settings: Settings):
    if settings.llm_provider == "openai":
        return OpenAiLlm()
    if settings.llm_provider == "anthropic":
        return AnthropicLlm()
    return LocalLlm()


def storage(settings: Settings):
    if settings.storage_engine == "redb":
        return RedbStorage()
    return FjallStorage()


def default_agents() -> dict[str, Agent]:
    agent = Agent(
        id=AgentId("default"),
        name="default",
        capabilities=[Capability.GENERATE, Capability.RETRIEVE],
    )
    return {agent.id.value: agent}


def default_graph() -> Graph:
    return Graph(
        nodes=[Node("r", "retrieve", "retrieve"), Node("g", "generate", "generate")],
        edges=[Edge("r", "g")],
    )
