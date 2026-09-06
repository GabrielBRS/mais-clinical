from ai_compute.core import (
    Buffer,
    Device,
    Model,
    ModelKind,
    Shape,
    StatusCode,
    Tensor,
    element_byte_size,
    enumerate_devices,
)
from ai_compute.runtime import ModelRegistry
from std.testing import assert_equal, assert_raises, assert_true, TestSuite


def test_dtype_float32() raises:
    assert_equal(element_byte_size(DType.float32), 4)
    assert_equal(String(DType.float32), "float32")


def test_shape() raises:
    var shape = Shape(2, 3)
    assert_equal(shape.rank(), 2)
    assert_equal(shape.numel(), 6)
    assert_equal(shape.byte_size(DType.float32), 24)


def test_shape_dynamic_dim() raises:
    var shape = Shape(2, -1)
    assert_equal(shape.numel(), -1)
    with assert_raises(contains="dinamica"):
        _ = shape.byte_size(DType.float32)


def test_tensor_zeros() raises:
    var tensor = Tensor.zeros(Shape(2, 2), DType.float32)
    assert_equal(tensor.nbytes(), 16)
    for b in tensor.buffer.data:
        assert_equal(Int(b), 0)


def test_tensor_from_host() raises:
    var bytes = List[UInt8](length=4, fill=7)
    var tensor = Tensor.from_host(Shape(4), DType.uint8, bytes)
    assert_equal(tensor.nbytes(), 4)
    assert_equal(Int(tensor.buffer.data[0]), 7)
    assert_equal(Int(tensor.buffer.data[3]), 7)


def test_tensor_from_host_size_mismatch() raises:
    var bytes = List[UInt8](length=3, fill=1)
    with assert_raises(contains="tamanho do buffer"):
        _ = Tensor.from_host(Shape(2, 2), DType.float32, bytes)


def test_gpu_buffer_unimplemented() raises:
    with assert_raises(contains="alocacao GPU"):
        _ = Buffer.allocate(16, Device.gpu())


def test_device() raises:
    assert_equal(Device.cpu().label(), "cpu:0")
    var devices = enumerate_devices()
    assert_true(len(devices) > 0)
    assert_true(devices[0].is_cpu())


def test_model_registry() raises:
    var registry = ModelRegistry()
    registry.register(
        Model(
            "m1", "mock", "llama_cpp", kind=ModelKind.llm, device=Device.cpu()
        )
    )
    assert_equal(len(registry.list()), 1)
    var loaded = registry.get("m1")
    assert_equal(loaded.kind_name(), "llm")


def test_model_registry_errors() raises:
    var registry = ModelRegistry()
    with assert_raises(contains="vazio"):
        registry.register(Model("", "mock", "stub"))
    registry.register(Model("m1", "mock", "stub"))
    with assert_raises(contains="ja registrado"):
        registry.register(Model("m1", "other", "stub"))
    with assert_raises(contains="nao encontrado"):
        _ = registry.get("missing")


def test_engine_error_code() raises:
    var raised = False
    try:
        _ = element_byte_size(DType.float8_e5m2)
    except e:
        raised = True
        assert_equal(e.code, StatusCode.invalid_argument)
    assert_true(raised)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
