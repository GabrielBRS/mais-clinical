from .error import VisionError
from .status import StatusCode


struct Image(Copyable):
    var width: Int
    var height: Int
    var channels: Int
    var data: List[UInt8]

    def __init__(out self):
        self.width = 0
        self.height = 0
        self.channels = 0
        self.data = List[UInt8]()

    def __init__(
        out self, width: Int, height: Int, channels: Int, var data: List[UInt8]
    ):
        self.width = width
        self.height = height
        self.channels = channels
        self.data = data^

    @staticmethod
    def zeros(
        width: Int, height: Int, channels: Int = 3
    ) raises VisionError -> Image:
        if width <= 0 or height <= 0 or channels <= 0:
            raise VisionError(
                StatusCode.invalid_argument, "dimensoes invalidas"
            )
        var n = width * height * channels
        return Image(width, height, channels, List[UInt8](length=n, fill=0))

    @staticmethod
    def from_rgb(
        width: Int, height: Int, bytes: List[UInt8]
    ) raises VisionError -> Image:
        var image = Image.zeros(width, height, 3)
        if len(bytes) != image.nbytes():
            raise VisionError(
                StatusCode.invalid_argument, "buffer nao bate com HxWx3"
            )
        var i = 0
        while i < len(bytes):
            image.data[i] = bytes[i]
            i += 1
        return image^

    def nbytes(self) -> Int:
        return len(self.data)

    def is_empty(self) -> Bool:
        return len(self.data) == 0

    def index_of(self, y: Int, x: Int, c: Int) raises VisionError -> Int:
        if (
            y < 0
            or y >= self.height
            or x < 0
            or x >= self.width
            or c < 0
            or c >= self.channels
        ):
            raise VisionError(
                StatusCode.invalid_argument, "indice fora da imagem"
            )
        return (y * self.width + x) * self.channels + c

    def at(self, y: Int, x: Int, c: Int) raises VisionError -> UInt8:
        return self.data[self.index_of(y, x, c)]

    def set(mut self, y: Int, x: Int, c: Int, value: UInt8) raises VisionError:
        self.data[self.index_of(y, x, c)] = value
