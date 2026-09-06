from vision.core.error import VisionError
from vision.core.image import Image
from vision.core.status import StatusCode
from vision.cpu.simd import scale_bias
from vision.core.tensor import Tensor


def resize_nearest(
    src: Image, width: Int, height: Int
) raises VisionError -> Image:
    if src.is_empty():
        raise VisionError(StatusCode.invalid_argument, "imagem vazia")
    var dst = Image.zeros(width, height, src.channels)
    var y = 0
    while y < height:
        var sy = y * src.height / height
        var x = 0
        while x < width:
            var sx = x * src.width / width
            var c = 0
            while c < src.channels:
                dst.set(y, x, c, src.at(sy, sx, c))
                c += 1
            x += 1
        y += 1
    return dst^


def rgb_to_bgr(src: Image) raises VisionError -> Image:
    if src.channels != 3:
        raise VisionError(
            StatusCode.invalid_argument, "rgb_to_bgr pede 3 canais"
        )
    var dst = Image.zeros(src.width, src.height, 3)
    var y = 0
    while y < src.height:
        var x = 0
        while x < src.width:
            dst.set(y, x, 0, src.at(y, x, 2))
            dst.set(y, x, 1, src.at(y, x, 1))
            dst.set(y, x, 2, src.at(y, x, 0))
            x += 1
        y += 1
    return dst^


def rgb_to_gray(src: Image) raises VisionError -> Image:
    if src.channels != 3:
        raise VisionError(
            StatusCode.invalid_argument, "rgb_to_gray pede 3 canais"
        )
    var dst = Image.zeros(src.width, src.height, 1)
    var y = 0
    while y < src.height:
        var x = 0
        while x < src.width:
            var r = Int(src.at(y, x, 0))
            var g = Int(src.at(y, x, 1))
            var b = Int(src.at(y, x, 2))
            var gray = (299 * r + 587 * g + 114 * b) / 1000
            dst.set(y, x, 0, UInt8(gray))
            x += 1
        y += 1
    return dst^


def normalize_nchw(
    src: Image, mean: Float32 = Float32(0.0), stddev: Float32 = Float32(255.0)
) raises VisionError -> Tensor:
    if src.is_empty() or stddev == Float32(0.0):
        raise VisionError(StatusCode.invalid_argument, "normalize invalido")
    var shape = List[Int](capacity=3)
    shape.append(src.channels)
    shape.append(src.height)
    shape.append(src.width)
    var tensor = Tensor.zeros(shape^)
    var plane = src.width * src.height
    var scale = Float32(1.0) / stddev
    var c = 0
    while c < src.channels:
        var y = 0
        while y < src.height:
            var x = 0
            while x < src.width:
                var index = c * plane + y * src.width + x
                tensor.values[index] = Float32(src.at(y, x, c))
                x += 1
            y += 1
        c += 1
    scale_bias(tensor.values, scale, -mean * scale)
    return tensor^


def image_to_nchw(src: Image) raises VisionError -> Tensor:
    return normalize_nchw(src)
