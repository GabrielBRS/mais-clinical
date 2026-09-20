@fieldwise_init
struct ExecutionStatus(Equatable, ImplicitlyCopyable, Writable):
    var _value: Int

    comptime pending = Self(0)
    comptime running = Self(1)
    comptime succeeded = Self(2)
    comptime failed = Self(3)
    comptime cancelled = Self(4)

    def name(self) -> String:
        if self == Self.pending:
            return "pending"
        if self == Self.running:
            return "running"
        if self == Self.succeeded:
            return "succeeded"
        if self == Self.failed:
            return "failed"
        if self == Self.cancelled:
            return "cancelled"
        return "unknown"

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.name())


def next_status(current: ExecutionStatus, event: String) -> ExecutionStatus:
    if event == "start":
        return ExecutionStatus.running
    if event == "ok":
        return ExecutionStatus.succeeded
    if event == "fail":
        return ExecutionStatus.failed
    return current


@fieldwise_init
struct ConversationState(Equatable, ImplicitlyCopyable, Writable):
    var _value: Int

    comptime open = Self(0)
    comptime waiting_tool = Self(1)
    comptime closed = Self(2)

    def name(self) -> String:
        if self == Self.open:
            return "open"
        if self == Self.waiting_tool:
            return "waiting_tool"
        if self == Self.closed:
            return "closed"
        return "unknown"

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.name())
