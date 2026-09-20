from vision.core.image import Image
from vision.preprocess import resize_nearest


def main() raises:
    var image = Image.zeros(64, 64, 3)
    var out = resize_nearest(image, 32, 32)
    print("resized", out.width, "x", out.height)
