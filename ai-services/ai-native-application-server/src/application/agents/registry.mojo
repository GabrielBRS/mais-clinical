from domain.agent import Agent, AgentRegistry


def default_agents() -> AgentRegistry:
    var registry = AgentRegistry()
    registry.add(AgentRegistry.default_agent())
    return registry^
