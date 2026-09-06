from ai_orchestrator.orchestration.routing.deterministic import pick as pick_id
from ai_orchestrator.orchestration.routing.semantic import pick as pick_semantic


class Router:
    def route(self, agent_id: str | None, prompt: str, available: list[str]) -> str:
        if agent_id:
            return pick_id(agent_id, available)
        return pick_semantic(prompt, available)
