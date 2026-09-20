from ai_orchestrator.adapter.llm.local import LocalLlm
from ai_orchestrator.adapter.vector.milvus import MilvusVector
from ai_orchestrator.bootstrap.dependencies import default_agents
from ai_orchestrator.usecase.execute_agent import ExecuteAgentCommand, ExecuteAgentUseCase


def test_execute_default_agent() -> None:
    usecase = ExecuteAgentUseCase(default_agents(), LocalLlm(), MilvusVector())
    result = usecase.execute(ExecuteAgentCommand("default", "hello"))
    assert result.text == "[local] hello"
    assert result.execution_id.startswith("exe-")
