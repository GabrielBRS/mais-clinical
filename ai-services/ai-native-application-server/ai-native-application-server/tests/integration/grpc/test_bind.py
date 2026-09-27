from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.transport.grpc.server import create_grpc_server


def test_grpc_server_can_be_created() -> None:
    assert create_grpc_server(AppContainer.build()) is not None
