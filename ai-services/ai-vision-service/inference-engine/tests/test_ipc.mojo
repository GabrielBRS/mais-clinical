from vision.core.status import StatusCode
from vision.ipc import Frame, Header, MessageType, decode_frame, encode_frame
from std.testing import assert_equal, assert_raises, TestSuite


def test_health_roundtrip() raises:
    var payload = List[UInt8]()
    payload.append(112)
    payload.append(105)
    payload.append(110)
    payload.append(103)
    var frame = Frame(
        Header(1, MessageType.health_request, 42, 0),
        payload^,
    )
    var wire = encode_frame(frame)
    var back = decode_frame(wire)
    assert_equal(back.header.type, MessageType.health_request)
    assert_equal(Int(back.header.request_id), 42)
    assert_equal(len(back.payload), 4)


def test_bad_magic() raises:
    var bytes = List[UInt8](length=20, fill=0)
    with assert_raises(contains="magic VPE1"):
        _ = decode_frame(bytes)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
