from .buffer import Buffer
from .device import Device
from .error import EngineError
from .shape import Shape
from .status import StatusCode


struct Tensor(Copyable):
    var buffer: Buffer
    var shape: Shape
    var dtype: DType

    def __init__(out self, var buffer: Buffer, var shape: Shape, dtype: DType):
        self.buffer = buffer^
        self.shape = shape^
        self.dtype = dtype

    @staticmethod
    def empty(
        var shape: Shape,
        dtype: DType,
        device: Device = Device.cpu(),
    ) raises EngineError -> Tensor:
        var nbytes = shape.byte_size(dtype)
        var buffer = Buffer.allocate(nbytes, device)
        return Tensor(buffer^, shape^, dtype)

    @staticmethod
    def zeros(
        var shape: Shape,
        dtype: DType,
        device: Device = Device.cpu(),
    ) raises EngineError -> Tensor:
        # Buffer.allocate fills host memory with zeros.
        return Tensor.empty(shape^, dtype, device)

    @staticmethod
    def from_host(
        var shape: Shape,
        dtype: DType,
        bytes: Span[UInt8, ...],
    ) raises EngineError -> Tensor:
        var nbytes = shape.byte_size(dtype)
        if len(bytes) != nbytes:
            raise EngineError(
                StatusCode.invalid_argument,
                "tamanho do buffer nao bate com shape/dtype",
            )
        var buffer = Buffer.allocate(nbytes, Device.cpu())
        for i in range(nbytes):
            buffer.data[i] = bytes[i]
        return Tensor(buffer^, shape^, dtype)

    def device(self) -> Device:
        return self.buffer.device

    def nbytes(self) -> Int:
        return self.buffer.byte_length()

    def is_empty(self) -> Bool:
        return self.buffer.is_empty()
