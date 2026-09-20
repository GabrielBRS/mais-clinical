from domain.message import Message
from domain.state import ConversationState


struct Conversation(Copyable):
    var id: String
    var messages: List[Message]
    var state: ConversationState

    def __init__(
        out self,
        var id: String,
        var messages: List[Message] = List[Message](),
        state: ConversationState = ConversationState.open,
    ):
        self.id = id^
        self.messages = messages^
        self.state = state

    def add(mut self, var message: Message):
        self.messages.append(message^)


struct ConversationMemory(Copyable):
    var conversations: List[Conversation]

    def __init__(out self):
        self.conversations = List[Conversation]()

    def save(mut self, var conversation: Conversation):
        var i = 0
        while i < len(self.conversations):
            if self.conversations[i].id == conversation.id:
                self.conversations[i] = conversation^
                return
            i += 1
        self.conversations.append(conversation^)

    def load(self, conversation_id: String) -> Optional[Conversation]:
        for conversation in self.conversations:
            if conversation.id == conversation_id:
                return Optional(conversation)
        return Optional[Conversation]()
