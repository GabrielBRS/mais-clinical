from ai_orchestrator.adapter.llm.local import LocalLlm
from ai_orchestrator.adapter.memory.redis import RedisMemory
from ai_orchestrator.adapter.vector.milvus import MilvusVector
from ai_orchestrator.domain.conversation import Conversation, ConversationId
from ai_orchestrator.domain.message import Message
from ai_orchestrator.domain.model import GenerationConfig


def test_llm_port_local() -> None:
    llm = LocalLlm()
    text = llm.generate([Message.user("hi")], GenerationConfig())
    assert text == "[local] hi"


def test_memory_roundtrip() -> None:
    memory = RedisMemory()
    conv = Conversation(id=ConversationId.new())
    conv.add(Message.user("x"))
    memory.save(conv)
    loaded = memory.load(conv.id.value)
    assert loaded is not None
    assert loaded.messages[0].content.text == "x"


def test_vector_search() -> None:
    store = MilvusVector()
    store.index(["rust retrieval ranking", "cuda kernels"])
    hits = store.search("retrieval", top_k=1)
    assert hits
