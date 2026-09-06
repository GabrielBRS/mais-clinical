from vision.core.error import VisionError
from vision.core.status import StatusCode
from vision.core.tensor import Tensor


@fieldwise_init
struct Kind(Equatable, ImplicitlyCopyable, Writable):
    var _value: Int

    comptime custom = Self(0)
    comptime tensorrt = Self(1)
    comptime onnxruntime = Self(2)
    comptime libtorch = Self(3)

    def name(self) -> String:
        if self == Self.custom:
            return "custom-identity"
        if self == Self.tensorrt:
            return "tensorrt"
        if self == Self.onnxruntime:
            return "onnxruntime"
        if self == Self.libtorch:
            return "libtorch"
        return "unknown"

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.name())


struct IdentityBackend(Copyable):
    def name(self) -> String:
        return Kind.custom.name()

    def available(self) -> Bool:
        return True

    def infer(self, input: Tensor) -> Tensor:
        return input.copy()


struct UnavailableBackend(Copyable):
    var kind: Kind

    def name(self) -> String:
        return self.kind.name()

    def available(self) -> Bool:
        return False

    def infer(self, input: Tensor) raises VisionError -> Tensor:
        raise VisionError(
            StatusCode.unavailable, String(self.name(), " indisponivel")
        )


def custom_available() -> Bool:
    return True


def tensorrt_available() -> Bool:
    return False


def onnxruntime_available() -> Bool:
    return False


def libtorch_available() -> Bool:
    return False


def make_identity() -> IdentityBackend:
    return IdentityBackend()


def make_unavailable(kind: Kind) -> UnavailableBackend:
    return UnavailableBackend(kind)
