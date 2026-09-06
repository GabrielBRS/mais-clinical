from .dtype import element_byte_size
from .error import EngineError
from .status import StatusCode


struct Shape(Copyable, Equatable, Writable):
    var dims: List[Int]

    def __init__(out self):
        self.dims = List[Int]()

    def __init__(out self, var *dims: Int):
        self.dims = List[Int](capacity=len(dims))
        for dim in dims:
            self.dims.append(dim)

    def __init__(out self, *, var dims: List[Int]):
        self.dims = dims^

    def rank(self) -> Int:
        return len(self.dims)

    def is_empty(self) -> Bool:
        return len(self.dims) == 0

    def __getitem__(self, axis: Int) raises EngineError -> Int:
        if axis < 0 or axis >= len(self.dims):
            raise EngineError(StatusCode.invalid_argument, "axis fora do rank")
        return self.dims[axis]

    def numel(self) -> Int:
        if self.is_empty():
            return 0
        var n: Int = 1
        for dim in self.dims:
            if dim < 0:
                return -1
            n *= dim
        return n

    def byte_size(self, dtype: DType) raises EngineError -> Int:
        var n = self.numel()
        if n < 0:
            raise EngineError(
                StatusCode.invalid_argument, "shape com dim dinamica"
            )
        return n * element_byte_size(dtype)

    def write_to(self, mut writer: Some[Writer]):
        writer.write("Shape(")
        for i in range(len(self.dims)):
            if i > 0:
                writer.write(", ")
            writer.write(self.dims[i])
        writer.write(")")
