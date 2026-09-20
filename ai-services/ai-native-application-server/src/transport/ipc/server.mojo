from application.application import Application
from infrastructure.ipc.unix_socket import UnixConnection, UnixListener


struct IPCServer:
    var path: String

    def __init__(out self, path: String):
        self.path = path

    def serve(mut self, mut app: Application) raises:
        var listener = UnixListener(self.path)
        print("ipc listening", self.path)
        while True:
            self.accept_once(app, listener)

    def accept_once(
        self, mut app: Application, listener: UnixListener
    ) raises:
        var conn = listener.accept()
        self.handle_connection(app, conn)

    def handle_connection(
        self, mut app: Application, mut conn: UnixConnection
    ):
        try:
            var incoming = conn.recv_frame()
            var outgoing = app.handle(incoming)
            conn.send_frame(outgoing)
        except e:
            print("ipc request failed", String(e))
        conn.close()
