from ai_orchestrator.adapter.llm.local import LocalLlm
from ai_orchestrator.domain.message import Message
from ai_orchestrator.domain.model import GenerationConfig


def test_local_generate_and_embed() -> None:
    llm = LocalLlm()
    assert llm.generate([Message.user("ping")], GenerationConfig()) == "[local] ping"
    assert len(llm.embed(["a", "b"])) == 2
