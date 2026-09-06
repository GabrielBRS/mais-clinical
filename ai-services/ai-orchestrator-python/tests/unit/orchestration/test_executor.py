from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.usecase.execute_agent import ExecuteAgentCommand
from ai_orchestrator.usecase.execute_workflow import ExecuteWorkflowCommand


def test_executors_run_through_container() -> None:
    container = AppContainer.build()
    agent = container.agent_executor.run(ExecuteAgentCommand("default", "hi"))
    workflow = container.workflow_executor.run(ExecuteWorkflowCommand("hi"))
    assert agent.text == "[local] hi"
    assert workflow.steps == ["retrieve", "generate"]
