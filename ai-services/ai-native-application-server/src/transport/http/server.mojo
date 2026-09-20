from application.application import Application
from infrastructure.net.tcp import TcpListener
from transport.http.errors import error_json
from transport.http.request import HTTPRequest
from transport.http.response import HTTPResponse
from transport.http.router import Router


struct HTTPServer:
    var router: Router
    var host: String
    var port: UInt16

    def __init__(out self, var router: Router, var host: String, port: UInt16):
        self.router = router^
        self.host = host^
        self.port = port

    def serve(mut self, mut app: Application) raises:
        var listener = TcpListener(self.host, Int(self.port))
        print("http listening", self.host, Int(self.port))
        while True:
            self.accept_once(app, listener)

    def accept_once(
        mut self, mut app: Application, listener: TcpListener
    ) raises:
        var conn = listener.accept()
        try:
            var raw = conn.recv_http()
            var response = self.handle(app, raw)
            conn.send_all(response.encode())
        except e:
            try:
                conn.send_all(
                    HTTPResponse.json(
                        500, error_json("internal", String(e))
                    ).encode()
                )
            except send_err:
                _ = send_err
        conn.close()

    def handle(mut self, mut app: Application, raw: String) raises -> HTTPResponse:
        var request = HTTPRequest.parse(raw)
        var endpoint = self.router.match(request.method, request.path)
        if not endpoint:
            return HTTPResponse.json(
                404, error_json("not_found", request.method + " " + request.path)
            )
        return endpoint.value().handle(app, request)
