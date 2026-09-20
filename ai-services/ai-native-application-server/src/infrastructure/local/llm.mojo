from domain.message import Message
from domain.model import GenerationConfig

from infrastructure.compute.kernels import hash_embed


struct LocalLlm(Copyable):
    """Deterministic local provider. Satisfies generate + embed without a vendor.
    """

    var _marker: Bool

    def __init__(out self):
        self._marker = True

    def generate(
        self, messages: List[Message], config: GenerationConfig
    ) -> String:
        _ = config
        if len(messages) == 0:
            return "[local] "
        return "[local] " + messages[len(messages) - 1].text

    def embed(self, texts: List[String]) -> List[List[Float64]]:
        var out = List[List[Float64]]()
        for text in texts:
            out.append(hash_embed(text))
        return out^
