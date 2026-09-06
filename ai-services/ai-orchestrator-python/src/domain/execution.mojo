from .state import ExecutionStatus


struct ExecutionResult(Copyable):
    var text: String
    var context: List[String]
    var steps: List[String]
    var execution_id: String

    def __init__(
        out self,
        var text: String,
        var context: List[String] = List[String](),
        var steps: List[String] = List[String](),
        var execution_id: String = "",
    ):
        self.text = text^
        self.context = context^
        self.steps = steps^
        self.execution_id = execution_id^


struct Execution(Copyable):
    var id: String
    var status: ExecutionStatus
    var result: ExecutionResult
    var error: String

    def __init__(
        out self,
        var id: String,
        status: ExecutionStatus = ExecutionStatus.pending,
        var result: ExecutionResult = ExecutionResult(""),
        var error: String = "",
    ):
        self.id = id^
        self.status = status
        self.result = result^
        self.error = error^
