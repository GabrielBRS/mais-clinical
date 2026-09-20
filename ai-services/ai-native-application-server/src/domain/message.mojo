@fieldwise_init
struct Role(Equatable, ImplicitlyCopyable, Writable):
    var _value: Int

    comptime system = Self(0)
    comptime user = Self(1)
    comptime assistant = Self(2)
    comptime tool = Self(3)

    def name(self) -> String:
        if self == Self.system:
            return "system"
        if self == Self.user:
            return "user"
        if self == Self.assistant:
            return "assistant"
        if self == Self.tool:
            return "tool"
        return "unknown"

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.name())


struct Message(Copyable):
    var role: Role
    var text: String

    def __init__(out self, role: Role, var text: String):
        self.role = role
        self.text = text^

    @staticmethod
    def system(var text: String) -> Message:
        return Message(Role.system, text^)

    @staticmethod
    def user(var text: String) -> Message:
        return Message(Role.user, text^)

    @staticmethod
    def assistant(var text: String) -> Message:
        return Message(Role.assistant, text^)
