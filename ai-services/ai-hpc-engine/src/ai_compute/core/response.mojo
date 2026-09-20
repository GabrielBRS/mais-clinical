from .status import Status
from .tensor import Tensor


struct Response(Copyable):
    var status: Status
    var outputs: List[Tensor]
    var text: String
    var scores: List[Float32]
    var done: Bool

    def __init__(out self, status: Status = Status.ok()):
        self.status = status
        self.outputs = List[Tensor]()
        self.text = ""
        self.scores = List[Float32]()
        self.done = True
