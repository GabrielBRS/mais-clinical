from ai_orchestrator.orchestration.routing.deterministic import pick


def main() -> None:
    pick("default", ["default", "research"])


if __name__ == "__main__":
    main()
