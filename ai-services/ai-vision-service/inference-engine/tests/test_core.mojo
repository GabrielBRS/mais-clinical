from vision.core.image import Image
from vision.gpu import device_count
from vision.preprocess import (
    normalize_nchw,
    resize_nearest,
    rgb_to_bgr,
    rgb_to_gray,
)
from std.testing import assert_equal, assert_raises, assert_true, TestSuite


def test_image_zeros() raises:
    var image = Image.zeros(4, 4, 3)
    assert_equal(image.nbytes(), 48)
    image.set(1, 2, 0, 200)
    image.set(1, 2, 1, 10)
    image.set(1, 2, 2, 10)
    assert_equal(Int(image.at(1, 2, 0)), 200)


def test_image_invalid() raises:
    with assert_raises(contains="dimensoes invalidas"):
        _ = Image.zeros(0, 4, 3)


def test_resize() raises:
    var image = Image.zeros(4, 4, 3)
    image.set(1, 2, 0, 200)
    var resized = resize_nearest(image, 8, 8)
    assert_equal(resized.width, 8)
    assert_equal(resized.height, 8)


def test_gray_bgr() raises:
    var image = Image.zeros(4, 4, 3)
    image.set(1, 2, 0, 200)
    image.set(1, 2, 1, 10)
    image.set(1, 2, 2, 10)
    var gray = rgb_to_gray(image)
    assert_equal(gray.channels, 1)
    assert_true(Int(gray.at(1, 2, 0)) >= 50)
    var bgr = rgb_to_bgr(image)
    assert_equal(Int(bgr.at(1, 2, 0)), 10)
    assert_equal(Int(bgr.at(1, 2, 2)), 200)


def test_normalize() raises:
    var image = Image.zeros(4, 4, 3)
    var tensor = normalize_nchw(image, Float32(0.0), Float32(255.0))
    assert_equal(tensor.rank(), 3)
    assert_equal(tensor.numel(), 48)


def test_device() raises:
    assert_true(device_count() >= 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
