from ai_orchestrator.adapter.memory.redis import RedisMemory
from ai_orchestrator.domain.conversation import Conversation, ConversationId
from ai_orchestrator.domain.message import Message


def test_memory_save_load() -> None:
    memory = RedisMemory()
    conv = Conversation(id=ConversationId.new())
    conv.add(Message.user("remember"))
    memory.save(conv)
    assert memory.load(conv.id.value) is conv
