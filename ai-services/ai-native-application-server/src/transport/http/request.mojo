from .text import skip_ws, slice_str


@fieldwise_init
struct HTTPRequest(Copyable):
    var method: String
    var path: String
    var query: String
    var body: String

    @staticmethod
    def parse(raw: String) raises -> HTTPRequest:
        var header_end = raw.find("\r\n\r\n")
        var head = raw
        var body = String()
        if header_end >= 0:
            head = slice_str(raw, 0, header_end)
            body = slice_str(raw, header_end + 4, raw.byte_length())
        var line_end = head.find("\r\n")
        var request_line = head
        if line_end >= 0:
            request_line = slice_str(head, 0, line_end)
        var method = String("GET")
        var target = String("/")
        var sp1 = request_line.find(" ")
        if sp1 >= 0:
            method = slice_str(request_line, 0, sp1)
            var rest = slice_str(
                request_line, skip_ws(request_line, sp1 + 1), request_line.byte_length()
            )
            var sp2 = rest.find(" ")
            if sp2 >= 0:
                target = slice_str(rest, 0, sp2)
            else:
                target = rest^
        var path = target.copy()
        var query = String()
        var q = target.find("?")
        if q >= 0:
            path = slice_str(target, 0, q)
            query = slice_str(target, q + 1, target.byte_length())
        if path.byte_length() == 0:
            path = "/"
        return HTTPRequest(method^, path^, query^, body^)
