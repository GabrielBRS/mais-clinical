from .device import Device


@fieldwise_init
struct ModelKind(Equatable, ImplicitlyCopyable, Writable):
    var _value: Int

    comptime llm = Self(0)
    comptime embedding = Self(1)
    comptime reranker = Self(2)
    comptime vision = Self(3)
    comptime multimodal = Self(4)
    comptime generic = Self(5)

    def name(self) -> String:
        if self == Self.llm:
            return "llm"
        if self == Self.embedding:
            return "embedding"
        if self == Self.reranker:
            return "reranker"
        if self == Self.vision:
            return "vision"
        if self == Self.multimodal:
            return "multimodal"
        if self == Self.generic:
            return "generic"
        return "unknown"

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.name())


struct Model(Copyable):
    var id: String
    var name: String
    var path: String
    var backend: String
    var kind: ModelKind
    var device: Device

    def __init__(
        out self,
        var id: String,
        var name: String,
        var backend: String,
        kind: ModelKind = ModelKind.generic,
        device: Device = Device.cpu(),
        var path: String = "",
    ):
        self.id = id^
        self.name = name^
        self.path = path^
        self.backend = backend^
        self.kind = kind
        self.device = device

    def kind_name(self) -> String:
        return self.kind.name()
