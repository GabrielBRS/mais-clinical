from transport.http.endpoint import Endpoint, HTTPHandler


struct Router(Copyable):
    var endpoints: List[Endpoint]

    def __init__(out self):
        self.endpoints = List[Endpoint]()

    def add(mut self, var endpoint: Endpoint):
        self.endpoints.append(endpoint^)

    def get(mut self, path: String, name: String, handler: HTTPHandler):
        self.add(Endpoint("GET", path, name, handler))

    def post(mut self, path: String, name: String, handler: HTTPHandler):
        self.add(Endpoint("POST", path, name, handler))

    def match(self, method: String, path: String) -> Optional[Endpoint]:
        for endpoint in self.endpoints:
            if endpoint.method == method and endpoint.path == path:
                return Optional(endpoint.copy())
        return Optional[Endpoint]()
