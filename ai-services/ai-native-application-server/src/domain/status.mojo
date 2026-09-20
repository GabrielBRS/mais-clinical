@fieldwise_init
struct StatusCode(Equatable, ImplicitlyCopyable, Writable):
    var _value: Int

    comptime ok = Self(0)
    comptime invalid_argument = Self(1)
    comptime not_found = Self(2)
    comptime already_exists = Self(3)
    comptime unavailable = Self(4)
    comptime unimplemented = Self(5)
    comptime internal = Self(6)
    comptime cancelled = Self(7)
    comptime resource_exhausted = Self(8)

    def name(self) -> String:
        if self == Self.ok:
            return "ok"
        if self == Self.invalid_argument:
            return "invalid_argument"
        if self == Self.not_found:
            return "not_found"
        if self == Self.already_exists:
            return "already_exists"
        if self == Self.unavailable:
            return "unavailable"
        if self == Self.unimplemented:
            return "unimplemented"
        if self == Self.internal:
            return "internal"
        if self == Self.cancelled:
            return "cancelled"
        if self == Self.resource_exhausted:
            return "resource_exhausted"
        return "unknown"

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.name())


@fieldwise_init
struct Status(Boolable, Copyable, Equatable, Writable):
    var code: StatusCode
    var message: String

    @staticmethod
    def ok() -> Self:
        return Self(StatusCode.ok, "")

    @staticmethod
    def from_code(code: StatusCode, var message: String) -> Self:
        return Self(code, message^)

    def is_ok(self) -> Bool:
        return self.code == StatusCode.ok

    def __bool__(self) -> Bool:
        return self.is_ok()

    def write_to(self, mut writer: Some[Writer]):
        if self.is_ok():
            writer.write("ok")
            return
        writer.write(self.code, ": ", self.message)
