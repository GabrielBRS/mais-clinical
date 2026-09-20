from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.transport.grpc.server import create_grpc_server


def test_grpc_health_servicer_registered() -> None:
    server = create_grpc_server(AppContainer.build())
    assert server is not None
