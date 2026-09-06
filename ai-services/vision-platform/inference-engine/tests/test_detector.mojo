from vision.core.image import Image
from vision.inference import BlobDetector, DetectorConfig
from std.testing import assert_true, TestSuite


def test_blob_detector() raises:
    var image = Image.zeros(32, 32, 3)
    var y = 8
    while y < 20:
        var x = 8
        while x < 20:
            image.set(y, x, 0, 255)
            image.set(y, x, 1, 255)
            image.set(y, x, 2, 255)
            x += 1
        y += 1
    var detector = BlobDetector(DetectorConfig(Float32(0.1), Float32(0.5), 16))
    var dets = detector.detect(image)
    assert_true(len(dets) > 0)
    assert_true(dets[0].box.w >= Float32(8.0))
    assert_true(dets[0].box.h >= Float32(8.0))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
