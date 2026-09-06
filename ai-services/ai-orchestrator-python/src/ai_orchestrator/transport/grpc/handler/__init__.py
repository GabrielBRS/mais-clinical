from grpc_health.v1 import health_pb2, health_pb2_grpc


class HealthServicer(health_pb2_grpc.HealthServicer):
    async def Check(self, request, context):
        return health_pb2.HealthCheckResponse(
            status=health_pb2.HealthCheckResponse.SERVING
        )


def build_health_servicer() -> HealthServicer:
    return HealthServicer()
