from std.sys.info import size_of

from .error import EngineError
from .status import StatusCode


def element_byte_size(dtype: DType) raises EngineError -> Int:
    """Return the host/device element stride for supported tensor dtypes."""
    if dtype == DType.float32:
        return size_of[DType.float32]()
    if dtype == DType.float16:
        return size_of[DType.float16]()
    if dtype == DType.bfloat16:
        return size_of[DType.bfloat16]()
    if dtype == DType.float64:
        return size_of[DType.float64]()
    if dtype == DType.int8:
        return size_of[DType.int8]()
    if dtype == DType.int16:
        return size_of[DType.int16]()
    if dtype == DType.int32:
        return size_of[DType.int32]()
    if dtype == DType.int64:
        return size_of[DType.int64]()
    if dtype == DType.uint8:
        return size_of[DType.uint8]()
    if dtype == DType.uint16:
        return size_of[DType.uint16]()
    if dtype == DType.uint32:
        return size_of[DType.uint32]()
    if dtype == DType.uint64:
        return size_of[DType.uint64]()
    if dtype == DType.bool:
        return size_of[DType.bool]()
    raise EngineError(
        StatusCode.invalid_argument, "dtype nao suportado para tensor"
    )
