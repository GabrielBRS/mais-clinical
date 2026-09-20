from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.usecase.execute_agent import ExecuteAgentCommand


def main() -> None:
    container = AppContainer.build()
    container.agent_executor.run(ExecuteAgentCommand("default", "bench"))


if __name__ == "__main__":
    main()
