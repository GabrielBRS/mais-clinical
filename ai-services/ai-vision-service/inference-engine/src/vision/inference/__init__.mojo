from vision.core.box import Box, Detection
from vision.core.image import Image
from vision.core.tensor import Tensor
from vision.postprocess import nms
from vision.preprocess import rgb_to_gray


@fieldwise_init
struct DetectorConfig(Copyable, ImplicitlyCopyable):
    var score_threshold: Float32
    var nms_iou: Float32
    var min_area: Int

    @staticmethod
    def default() -> Self:
        return Self(Float32(0.25), Float32(0.45), 16)


@fieldwise_init
struct ClassScore(Copyable, ImplicitlyCopyable):
    var class_id: Int
    var score: Float32


@fieldwise_init
struct _Rect(Copyable, ImplicitlyCopyable):
    var x0: Int
    var y0: Int
    var x1: Int
    var y1: Int
    var area: Int


@fieldwise_init
struct _Point(Copyable, ImplicitlyCopyable):
    var x: Int
    var y: Int


def _flood(
    gray: Image, mut seen: List[UInt8], x: Int, y: Int, mut rect: _Rect
) raises:
    var w = gray.width
    var h = gray.height
    var stack = List[_Point]()
    stack.append(_Point(x, y))
    while len(stack) > 0:
        var p = stack.pop()
        if p.x < 0 or p.y < 0 or p.x >= w or p.y >= h:
            continue
        var idx = p.y * w + p.x
        if seen[idx] != 0 or gray.at(p.y, p.x, 0) < 128:
            continue
        seen[idx] = 1
        if p.x < rect.x0:
            rect.x0 = p.x
        if p.y < rect.y0:
            rect.y0 = p.y
        if p.x > rect.x1:
            rect.x1 = p.x
        if p.y > rect.y1:
            rect.y1 = p.y
        rect.area += 1
        stack.append(_Point(p.x + 1, p.y))
        stack.append(_Point(p.x - 1, p.y))
        stack.append(_Point(p.x, p.y + 1))
        stack.append(_Point(p.x, p.y - 1))


struct BlobDetector(Copyable):
    var config: DetectorConfig

    def __init__(out self, config: DetectorConfig = DetectorConfig.default()):
        self.config = config

    def name(self) -> String:
        return "blob-detector"

    def detect(self, image: Image) raises -> List[Detection]:
        var gray = image.copy()
        if image.channels != 1:
            gray = rgb_to_gray(image)
        var w = gray.width
        var h = gray.height
        var seen = List[UInt8](length=w * h, fill=0)
        var detections = List[Detection]()
        var y = 0
        while y < h:
            var x = 0
            while x < w:
                var idx = y * w + x
                if seen[idx] == 0 and gray.at(y, x, 0) >= 128:
                    var rect = _Rect(x, y, x, y, 0)
                    _flood(gray, seen, x, y, rect)
                    if rect.area >= self.config.min_area:
                        var score = min(
                            Float32(1.0), Float32(rect.area) / Float32(64.0)
                        )
                        if score >= self.config.score_threshold:
                            detections.append(
                                Detection(
                                    Box(
                                        Float32(rect.x0),
                                        Float32(rect.y0),
                                        Float32(rect.x1 - rect.x0 + 1),
                                        Float32(rect.y1 - rect.y0 + 1),
                                        score,
                                        0,
                                    ),
                                    "blob",
                                    -1,
                                )
                            )
                x += 1
            y += 1
        return nms(detections^, self.config.nms_iou)


def make_blob_detector(
    config: DetectorConfig = DetectorConfig.default(),
) -> BlobDetector:
    return BlobDetector(config)


def classify_brightness(image: Image) -> ClassScore:
    if image.is_empty():
        return ClassScore(0, Float32(0.0))
    var sum: Int = 0
    for value in image.data:
        sum += Int(value)
    var mean = Float32(sum) / Float32(image.nbytes())
    var class_id = 0
    if mean > Float32(127.0):
        class_id = 1
    return ClassScore(class_id, min(Float32(1.0), mean / Float32(255.0)))


def threshold_mask(gray: Image, thresh: UInt8 = 128) raises -> Image:
    var mask = Image.zeros(gray.width, gray.height, 1)
    var i = 0
    var n = min(len(gray.data), len(mask.data))
    while i < n:
        if gray.data[i] >= thresh:
            mask.data[i] = 255
        else:
            mask.data[i] = 0
        i += 1
    return mask^


def embed_mean(image: Image, dim: Int = 8) raises -> Tensor:
    var shape = List[Int](capacity=1)
    shape.append(dim)
    var tensor = Tensor.zeros(shape^)
    if image.is_empty():
        return tensor^
    var n = dim
    var i = 0
    while i < image.nbytes():
        tensor.values[i % n] = tensor.values[i % n] + Float32(image.data[i])
        i += 1
    return tensor^


def caption_stub(image: Image) -> String:
    if image.is_empty():
        return "empty"
    return String("image ", image.width, "x", image.height)
