@fieldwise_init
struct HTTPResponse(Copyable):
    var status: Int
    var reason: String
    var content_type: String
    var body: String

    @staticmethod
    def json(status: Int, var body: String) -> HTTPResponse:
        return HTTPResponse(status, _reason(status), "application/json", body^)

    @staticmethod
    def text(status: Int, var body: String) -> HTTPResponse:
        return HTTPResponse(status, _reason(status), "text/plain; charset=utf-8", body^)

    def encode(self) -> String:
        var out = String("HTTP/1.1 ")
        out += String(self.status)
        out += " "
        out += self.reason
        out += "\r\nContent-Type: "
        out += self.content_type
        out += "\r\nContent-Length: "
        out += String(self.body.byte_length())
        out += "\r\nConnection: close\r\n\r\n"
        out += self.body
        return out^


def _reason(status: Int) -> String:
    if status == 200:
        return "OK"
    if status == 201:
        return "Created"
    if status == 400:
        return "Bad Request"
    if status == 404:
        return "Not Found"
    if status == 405:
        return "Method Not Allowed"
    if status == 500:
        return "Internal Server Error"
    if status == 503:
        return "Service Unavailable"
    return "OK"
