from ai_orchestrator.domain.message import Message


def to_openai(messages: list[Message]) -> list[dict[str, str]]:
    return [{"role": m.role.value, "content": m.content.text} for m in messages]
