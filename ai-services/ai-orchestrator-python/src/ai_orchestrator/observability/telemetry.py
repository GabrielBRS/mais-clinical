from ai_orchestrator.observability.logging import setup_logging


def boot(level: str) -> None:
    setup_logging(level)
