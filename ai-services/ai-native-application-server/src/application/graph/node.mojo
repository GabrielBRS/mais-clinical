struct Node(Copyable):
    var id: String
    var kind: String
    var label: String

    def __init__(
        out self, var id: String, var kind: String, var label: String = ""
    ):
        self.id = id^
        self.kind = kind^
        self.label = label^
