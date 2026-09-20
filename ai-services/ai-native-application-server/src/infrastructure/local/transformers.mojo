from domain.message import Message
from domain.model import GenerationConfig
from infrastructure.local.llm import LocalLlm


struct TransformersRuntime(Copyable):
    """Local generate facade. External model serving stays out of process."""

    var llm: LocalLlm

    def __init__(out self):
        self.llm = LocalLlm()

    def ping(self) -> String:
        return "{\"backend\":\"local\",\"owner\":\"mojo\"}"

    def generate_batch(self, prompts: List[String]) -> List[String]:
        var out = List[String]()
        for prompt in prompts:
            var messages = List[Message]()
            messages.append(Message.user(prompt.copy()))
            out.append(self.llm.generate(messages, GenerationConfig.default()))
        return out^
