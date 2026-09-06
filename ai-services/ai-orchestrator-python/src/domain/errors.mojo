from .status import StatusCode


@fieldwise_init
struct OrchestratorError(Copyable, Equatable, Writable):
    """Typed API failure: status code plus a contextual message."""

    var code: StatusCode
    var message: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.code, ": ", self.message)


def agent_not_found(var agent_id: String) -> OrchestratorError:
    return OrchestratorError(
        StatusCode.not_found, "agent nao encontrado: " + agent_id
    )


def graph_empty() -> OrchestratorError:
    return OrchestratorError(StatusCode.invalid_argument, "graph vazio")


def node_not_found(var node_id: String) -> OrchestratorError:
    return OrchestratorError(
        StatusCode.not_found, "node nao encontrado: " + node_id
    )
