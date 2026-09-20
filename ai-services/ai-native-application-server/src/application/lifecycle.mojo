struct Lifecycle(Copyable):
    var running: Bool

    def __init__(out self):
        self.running = False

    def start(mut self):
        self.running = True

    def stop(mut self):
        self.running = False

    def is_running(self) -> Bool:
        return self.running
