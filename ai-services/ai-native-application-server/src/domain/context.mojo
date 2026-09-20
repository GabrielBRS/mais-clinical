struct RuntimeContext(Copyable):
    var request_id: String
    var cancelled: Bool

    def __init__(out self, var request_id: String, cancelled: Bool = False):
        self.request_id = request_id^
        self.cancelled = cancelled

    def cancel(mut self):
        self.cancelled = True
