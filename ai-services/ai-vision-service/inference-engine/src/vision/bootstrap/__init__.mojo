from std.python import Python

from vision import VERSION
from vision.concurrency import RequestCounter
from vision.core.box import Detection
from vision.core.image import Image
from vision.inference import BlobDetector, DetectorConfig
from vision.ipc import Frame, Header, MessageType
from vision.ipc.unix_socket import UnixSocket
from vision.serving import grpc_bound, http_bound
from vision.telemetry.health import check


@fieldwise_init
struct Settings(Copyable):
    var app_name: String
    var http_host: String
    var http_port: UInt16
    var grpc_host: String
    var grpc_port: UInt16
    var ipc_path: String
    var detector: DetectorConfig

    @staticmethod
    def default() -> Self:
        return Self(
            "vision-inference-engine",
            "0.0.0.0",
            8083,
            "0.0.0.0",
            50054,
            "/tmp/vision-inference.sock",
            DetectorConfig.default(),
        )

    @staticmethod
    def from_env() raises -> Self:
        var settings = Self.default()
        try:
            var os = Python.import_module("os")
            var path = os.environ.get("VPE_IPC_PATH")
            if path:
                settings.ipc_path = String(path)
        except e:
            pass
        return settings^


struct Application:
    var settings: Settings
    var detector: BlobDetector
    var requests: RequestCounter

    def __init__(out self, var settings: Settings, var detector: BlobDetector):
        self.settings = settings^
        self.detector = detector^
        self.requests = RequestCounter()

    def detect(self, image: Image) raises -> List[Detection]:
        return self.detector.detect(image)

    def handle(mut self, incoming: Frame) -> Frame:
        _ = self.requests.add()
        var out = Frame(
            Header(
                incoming.header.version,
                MessageType.error,
                incoming.header.request_id,
                0,
            )
        )
        if incoming.header.type == MessageType.health_request:
            out.header.type = MessageType.health_response
            var i = 0
            while i < VERSION.byte_length():
                out.payload.append(VERSION.as_bytes()[i])
                i += 1
            return out^
        var msg = "unimplemented"
        var i = 0
        while i < msg.byte_length():
            out.payload.append(msg.as_bytes()[i])
            i += 1
        return out^

    def serve(mut self) raises -> Int:
        var server = UnixSocket.listen(self.settings.ipc_path)
        print(
            "ipc://",
            self.settings.ipc_path,
            " http://",
            self.settings.http_host,
            ":",
            Int(self.settings.http_port),
            end="",
        )
        if grpc_bound():
            print(
                " grpc://",
                self.settings.grpc_host,
                ":",
                Int(self.settings.grpc_port),
                end="",
            )
        print()
        _ = http_bound()
        var health = check()
        print("ready=", health.ready, " version=", health.version)
        var client = server.accept()
        var incoming = client.recv()
        var outgoing = self.handle(incoming)
        client.send(outgoing)
        return 0


def make_application(var settings: Settings) -> Application:
    return Application(settings^, BlobDetector(settings.detector))


def run() raises -> Int:
    var app = make_application(Settings.from_env())
    return app.serve()
