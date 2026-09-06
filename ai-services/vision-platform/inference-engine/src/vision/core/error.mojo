from .status import StatusCode


@fieldwise_init
struct VisionError(Copyable, Equatable, Writable):
    """Typed API failure: status code plus a contextual message."""

    var code: StatusCode
    var message: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.code, ": ", self.message)
