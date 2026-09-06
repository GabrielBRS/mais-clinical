"""Client gRPC — health em grpc://127.0.0.1:50051 quando o processo estiver no ar."""

from __future__ import annotations

import asyncio

import grpc
from grpc_health.v1 import health_pb2, health_pb2_grpc


async def main() -> None:
    async with grpc.aio.insecure_channel("127.0.0.1:50051") as channel:
        stub = health_pb2_grpc.HealthStub(channel)
        try:
            reply = await stub.Check(health_pb2.HealthCheckRequest(), timeout=2)
        except grpc.aio.AioRpcError as exc:
            print("orchestrator nao esta ouvindo:", exc)
            return
        print("health", reply.status)


if __name__ == "__main__":
    asyncio.run(main())
