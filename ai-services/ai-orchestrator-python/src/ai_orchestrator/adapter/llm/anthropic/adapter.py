from ai_orchestrator.domain.message import Message
from ai_orchestrator.domain.model import GenerationConfig


class AnthropicLlm:
    def generate(self, messages: list[Message], config: GenerationConfig) -> str:
        del messages, config
        raise RuntimeError("anthropic: adapter nao ligado")
