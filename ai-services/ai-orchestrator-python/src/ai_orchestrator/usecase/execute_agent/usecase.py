from __future__ import annotations

from ai_orchestrator.domain.agent import AgentNotFound
from ai_orchestrator.domain.execution import ExecutionId
from ai_orchestrator.domain.message import Message
from ai_orchestrator.domain.model import GenerationConfig
from ai_orchestrator.usecase.execute_agent.command import ExecuteAgentCommand
from ai_orchestrator.usecase.execute_agent.result import ExecuteAgentResult


class ExecuteAgentUseCase:
    def __init__(self, agents: dict, llm, vector) -> None:
        self._agents = agents
        self._llm = llm
        self._vector = vector

    def execute(self, command: ExecuteAgentCommand) -> ExecuteAgentResult:
        agent = self._agents.get(command.agent_id)
        if agent is None:
            raise AgentNotFound(command.agent_id)
        context: list[str] = []
        prompt = command.prompt
        if command.retrieve and agent.policy.allow_retrieval:
            context = self._vector.search(command.prompt, top_k=4)
            if context:
                prompt = "Context:\n" + "\n".join(context) + "\n\n" + command.prompt
        messages = [Message.system(agent.system_prompt), Message.user(prompt)]
        text = self._llm.generate(messages, GenerationConfig(max_tokens=agent.policy.max_tokens))
        return ExecuteAgentResult(ExecutionId.new().value, text, context)
