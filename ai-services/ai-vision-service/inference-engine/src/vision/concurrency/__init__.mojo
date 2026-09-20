struct RequestCounter:
    var value: UInt64

    def __init__(out self):
        self.value = 0

    def add(mut self, n: UInt64 = 1) -> UInt64:
        self.value += n
        return self.value


def global_request_counter() -> RequestCounter:
    return RequestCounter()
