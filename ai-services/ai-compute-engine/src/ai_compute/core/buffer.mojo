from .device import Device
from .error import EngineError
from .status import StatusCode


struct Buffer(Copyable):
    """Owned contiguous host bytes. GPU allocation is unimplemented in 01-core.
    """

    var data: List[UInt8]
    var device: Device

    def __init__(out self):
        self.data = List[UInt8]()
        self.device = Device.cpu()

    def __init__(out self, var data: List[UInt8], device: Device):
        self.data = data^
        self.device = device

    @staticmethod
    def allocate(
        byte_count: Int, device: Device = Device.cpu()
    ) raises EngineError -> Buffer:
        if device.is_gpu():
            raise EngineError(
                StatusCode.unimplemented,
                "alocacao GPU ainda nao ligada",
            )
        if byte_count < 0:
            raise EngineError(
                StatusCode.invalid_argument, "tamanho de buffer negativo"
            )
        if byte_count == 0:
            return Buffer()
        return Buffer(List[UInt8](length=byte_count, fill=0), device)

    def byte_length(self) -> Int:
        return len(self.data)

    def is_empty(self) -> Bool:
        return len(self.data) == 0
