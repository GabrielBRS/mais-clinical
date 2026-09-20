from .error import VisionError
from .status import StatusCode


def numel_of(shape: List[Int]) raises VisionError -> Int:
    if len(shape) < 1 or len(shape) > 8:
        raise VisionError(StatusCode.invalid_argument, "rank invalido")
    var n: Int = 1
    for dim in shape:
        if dim <= 0:
            raise VisionError(StatusCode.invalid_argument, "shape invalida")
        n *= dim
    return n


struct Tensor(Copyable):
    var shape: List[Int]
    var values: List[Float32]

    def __init__(out self):
        self.shape = List[Int]()
        self.values = List[Float32]()

    def __init__(out self, var shape: List[Int], var values: List[Float32]):
        self.shape = shape^
        self.values = values^

    @staticmethod
    def zeros(var shape: List[Int]) raises VisionError -> Tensor:
        var n = numel_of(shape)
        return Tensor(shape^, List[Float32](length=n, fill=Float32(0.0)))

    @staticmethod
    def from_host(
        var shape: List[Int], values: List[Float32]
    ) raises VisionError -> Tensor:
        var n = numel_of(shape)
        if len(values) != n:
            raise VisionError(
                StatusCode.invalid_argument, "valores nao batem com shape"
            )
        var copied = List[Float32](capacity=n)
        for value in values:
            copied.append(value)
        return Tensor(shape^, copied^)

    def numel(self) -> Int:
        return len(self.values)

    def rank(self) -> Int:
        return len(self.shape)

    def is_empty(self) -> Bool:
        return len(self.values) == 0
