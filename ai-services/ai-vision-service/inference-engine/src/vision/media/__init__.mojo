from vision.core.image import Image


def synthetic_frame(width: Int, height: Int) raises -> Image:
    var image = Image.zeros(width, height, 3)
    var x0 = width / 4
    var y0 = height / 4
    var x1 = (width * 3) / 4
    var y1 = (height * 3) / 4
    var y = y0
    while y < y1:
        var x = x0
        while x < x1:
            image.set(y, x, 0, 255)
            image.set(y, x, 1, 255)
            image.set(y, x, 2, 255)
            x += 1
        y += 1
    return image^


def camera_available() -> Bool:
    return False


def rtsp_available() -> Bool:
    return False


def jpeg_available() -> Bool:
    return False


def png_available() -> Bool:
    return False


def video_available() -> Bool:
    return False


def image_encode_available() -> Bool:
    return True


def default_fps() -> Int:
    return 30
