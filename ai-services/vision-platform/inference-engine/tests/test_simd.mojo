from vision.cpu.simd import axpy, dot, nrm2, scale_bias
from std.testing import assert_true, TestSuite


def test_scale_bias() raises:
    var values = List[Float32]()
    values.append(Float32(1.0))
    values.append(Float32(2.0))
    values.append(Float32(3.0))
    values.append(Float32(4.0))
    values.append(Float32(5.0))
    values.append(Float32(6.0))
    values.append(Float32(7.0))
    values.append(Float32(8.0))
    values.append(Float32(9.0))
    scale_bias(values, Float32(2.0), Float32(1.0))
    assert_true(values[0] == Float32(3.0))
    assert_true(values[7] == Float32(17.0))
    assert_true(values[8] == Float32(19.0))


def test_dot_axpy_nrm2() raises:
    var a = List[Float32]()
    var b = List[Float32]()
    var i = 0
    while i < 9:
        a.append(Float32(1.0))
        b.append(Float32(2.0))
        i += 1
    assert_true(dot(a, b) == Float32(18.0))
    axpy(Float32(3.0), a, b)
    assert_true(b[0] == Float32(5.0))
    assert_true(nrm2(a) > Float32(2.9))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
