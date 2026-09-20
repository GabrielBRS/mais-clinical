from domain.errors import OrchestratorError
from domain.status import StatusCode


struct TrainingRuntime(Copyable):
    """Training stays out of this process. Local facade only reports status."""

    var _marker: Bool

    def __init__(out self):
        self._marker = True

    def ping(self) -> String:
        return "{\"backend\":\"local\",\"owner\":\"mojo\"}"

    def train(self, config: String) raises -> String:
        _ = config
        raise OrchestratorError(
            StatusCode.unimplemented, "treino nao roda neste processo"
        )
