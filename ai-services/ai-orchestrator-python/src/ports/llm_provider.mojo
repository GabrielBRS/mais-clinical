from domain.message import Message
from domain.model import GenerationConfig


trait LLMProvider:
    """Coarse-grained generation. Domain never imports a vendor SDK."""

    def generate(
        self, messages: List[Message], config: GenerationConfig
    ) raises -> String:
        ...
