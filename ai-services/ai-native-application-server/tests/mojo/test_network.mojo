from infrastructure.ipc.unix_socket import UnixListener
from infrastructure.net.tcp import TcpListener
from std.testing import TestSuite


def test_tcp_bind_and_close() raises:
    var listener = TcpListener("127.0.0.1", 18081)
    listener.close()


def test_unix_bind_and_close() raises:
    var listener = UnixListener("/tmp/agentd-network-test.sock")
    listener.close()


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
