from std.math import sqrt

from vision.core.error import VisionError
from vision.core.status import StatusCode


comptime SIMD_WIDTH = 8


def _load8(values: List[Float32], i: Int) -> SIMD[DType.float32, SIMD_WIDTH]:
    return SIMD[DType.float32, SIMD_WIDTH](
        values[i],
        values[i + 1],
        values[i + 2],
        values[i + 3],
        values[i + 4],
        values[i + 5],
        values[i + 6],
        values[i + 7],
    )


def _store8(
    mut values: List[Float32], i: Int, lane: SIMD[DType.float32, SIMD_WIDTH]
):
    values[i] = lane[0]
    values[i + 1] = lane[1]
    values[i + 2] = lane[2]
    values[i + 3] = lane[3]
    values[i + 4] = lane[4]
    values[i + 5] = lane[5]
    values[i + 6] = lane[6]
    values[i + 7] = lane[7]


def scale_bias(mut values: List[Float32], scale: Float32, bias: Float32):
    var n = len(values)
    var i = 0
    var s = SIMD[DType.float32, SIMD_WIDTH](scale)
    var b = SIMD[DType.float32, SIMD_WIDTH](bias)
    while i + SIMD_WIDTH <= n:
        var lane = _load8(values, i)
        lane = lane * s + b
        _store8(values, i, lane)
        i += SIMD_WIDTH
    while i < n:
        values[i] = values[i] * scale + bias
        i += 1


def dot(a: List[Float32], b: List[Float32]) -> Float32:
    var n = min(len(a), len(b))
    var i = 0
    var acc = SIMD[DType.float32, SIMD_WIDTH](Float32(0.0))
    while i + SIMD_WIDTH <= n:
        acc = acc + _load8(a, i) * _load8(b, i)
        i += SIMD_WIDTH
    var sum = acc.reduce_add()
    while i < n:
        sum = sum + a[i] * b[i]
        i += 1
    return sum


def axpy(
    alpha: Float32, x: List[Float32], mut y: List[Float32]
) raises VisionError:
    var n = min(len(x), len(y))
    if n != len(y) and len(x) < len(y):
        raise VisionError(
            StatusCode.invalid_argument, "axpy: x mais curto que y"
        )
    var i = 0
    var scale = SIMD[DType.float32, SIMD_WIDTH](alpha)
    while i + SIMD_WIDTH <= n:
        var yv = scale * _load8(x, i) + _load8(y, i)
        _store8(y, i, yv)
        i += SIMD_WIDTH
    while i < n:
        y[i] = alpha * x[i] + y[i]
        i += 1


def nrm2(x: List[Float32]) -> Float32:
    return sqrt(dot(x, x))
