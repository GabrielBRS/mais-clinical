@fieldwise_init
struct Provider(Equatable, ImplicitlyCopyable, Writable):
    var _value: Int

    comptime local = Self(0)
    comptime openai = Self(1)
    comptime anthropic = Self(2)
    comptime compute_engine = Self(3)

    def name(self) -> String:
        if self == Self.local:
            return "local"
        if self == Self.openai:
            return "openai"
        if self == Self.anthropic:
            return "anthropic"
        if self == Self.compute_engine:
            return "compute_engine"
        return "unknown"

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.name())

    @staticmethod
    def parse(name: String) -> Self:
        if name == "openai":
            return Self.openai
        if name == "anthropic":
            return Self.anthropic
        if name == "compute_engine":
            return Self.compute_engine
        return Self.local


@fieldwise_init
struct GenerationConfig(Copyable, ImplicitlyCopyable):
    var max_tokens: Int
    var temperature: Float64
    var top_p: Float64

    @staticmethod
    def default() -> Self:
        return Self(256, 0.7, 1.0)

    @staticmethod
    def with_max_tokens(max_tokens: Int) -> Self:
        return Self(max_tokens, 0.7, 1.0)
