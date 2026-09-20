from vision.core.box import Box, Detection, iou
from vision.postprocess import nms
from std.testing import assert_equal, assert_true, TestSuite


def test_iou_overlap() raises:
    var a = Box(
        Float32(0.0),
        Float32(0.0),
        Float32(10.0),
        Float32(10.0),
        Float32(0.9),
        0,
    )
    var b = Box(
        Float32(1.0),
        Float32(1.0),
        Float32(10.0),
        Float32(10.0),
        Float32(0.8),
        0,
    )
    assert_true(iou(a, b) > Float32(0.5))


def test_iou_far() raises:
    var a = Box(
        Float32(0.0),
        Float32(0.0),
        Float32(10.0),
        Float32(10.0),
        Float32(0.9),
        0,
    )
    var c = Box(
        Float32(50.0),
        Float32(50.0),
        Float32(4.0),
        Float32(4.0),
        Float32(0.7),
        1,
    )
    assert_true(iou(a, c) < Float32(0.01))


def test_nms_keeps_two() raises:
    var a = Box(
        Float32(0.0),
        Float32(0.0),
        Float32(10.0),
        Float32(10.0),
        Float32(0.9),
        0,
    )
    var b = Box(
        Float32(1.0),
        Float32(1.0),
        Float32(10.0),
        Float32(10.0),
        Float32(0.8),
        0,
    )
    var c = Box(
        Float32(50.0),
        Float32(50.0),
        Float32(4.0),
        Float32(4.0),
        Float32(0.7),
        1,
    )
    var dets = List[Detection]()
    dets.append(Detection(a, "a", -1))
    dets.append(Detection(b, "b", -1))
    dets.append(Detection(c, "c", -1))
    var kept = nms(dets^, Float32(0.5))
    assert_equal(len(kept), 2)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
