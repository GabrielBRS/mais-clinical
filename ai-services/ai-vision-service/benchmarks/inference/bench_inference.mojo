from vision.core.image import Image
from vision.inference import BlobDetector


def main() raises:
    var image = Image.zeros(48, 48, 3)
    var detector = BlobDetector()
    var dets = detector.detect(image)
    print("detections", len(dets))
