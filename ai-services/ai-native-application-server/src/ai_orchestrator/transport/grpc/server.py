from __future__ import annotations

import grpc
from grpc_health.v1 import health_pb2_grpc

from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.transport.grpc.handler import build_health_servicer


def create_grpc_server(container: AppContainer) -> grpc.aio.Server:
    server = grpc.aio.server()
    health_pb2_grpc.add_HealthServicer_to_server(build_health_servicer(), server)
    listen = f"{container.settings.grpc_host}:{container.settings.grpc_port}"
    server.add_insecure_port(listen)
    return server
