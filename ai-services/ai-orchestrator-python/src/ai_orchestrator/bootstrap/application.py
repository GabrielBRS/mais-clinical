"""Sobe HTTP (FastAPI), gRPC e IPC ACE1 no mesmo processo asyncio."""

from __future__ import annotations

import asyncio
import json
import logging
import os
import signal
import socket

import uvicorn

from ai_orchestrator.adapter.ipc.unix_socket.connection import AceConnection
from ai_orchestrator.adapter.ipc.unix_socket.protocol import Frame, MessageType
from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.bootstrap.lifecycle import shutdown
from ai_orchestrator.observability.logging import setup_logging
from ai_orchestrator.transport.grpc.server import create_grpc_server
from ai_orchestrator.transport.http import create_http_app
from ai_orchestrator.usecase.execute_agent import ExecuteAgentCommand
from ai_orchestrator.usecase.execute_workflow import ExecuteWorkflowCommand

_log = logging.getLogger("ai_orchestrator.bootstrap")


class Application:
    def __init__(self, container: AppContainer) -> None:
        self._container = container
        self._http_app = create_http_app(container)
        self._grpc_server = create_grpc_server(container)
        self._uvicorn: uvicorn.Server | None = None

    async def serve(self) -> None:
        settings = self._container.settings
        config = uvicorn.Config(
            self._http_app,
            host=settings.http_host,
            port=settings.http_port,
            log_level=settings.log_level.lower(),
            loop="asyncio",
        )
        self._uvicorn = uvicorn.Server(config)
        self._uvicorn.install_signal_handlers = False

        loop = asyncio.get_running_loop()
        stop = asyncio.Event()
        for sig in (signal.SIGINT, signal.SIGTERM):
            loop.add_signal_handler(sig, stop.set)

        _log.info(
            "http://%s:%s  grpc://%s:%s  ipc://%s",
            settings.http_host,
            settings.http_port,
            settings.grpc_host,
            settings.grpc_port,
            settings.ipc_path,
        )

        http_task = asyncio.create_task(self._uvicorn.serve(), name="http")
        grpc_task = asyncio.create_task(self._serve_grpc(), name="grpc")
        ipc_task = asyncio.create_task(self._serve_ipc(stop), name="ipc")

        await stop.wait()
        await shutdown(self._uvicorn, self._grpc_server, http_task, grpc_task, ipc_task)

    async def _serve_grpc(self) -> None:
        await self._grpc_server.start()
        await self._grpc_server.wait_for_termination()

    async def _serve_ipc(self, stop: asyncio.Event) -> None:
        path = self._container.settings.ipc_path
        if os.path.exists(path):
            os.unlink(path)
        server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        server.bind(path)
        server.listen(16)
        server.setblocking(False)
        loop = asyncio.get_running_loop()
        while not stop.is_set():
            try:
                client, _ = await asyncio.wait_for(loop.sock_accept(server), timeout=0.2)
            except TimeoutError:
                continue
            loop.create_task(self._handle_ipc(client))
        server.close()

    async def _handle_ipc(self, client: socket.socket) -> None:
        conn = AceConnection(client)
        try:
            incoming = await asyncio.to_thread(conn.recv)
            outgoing = self._dispatch(incoming)
            await asyncio.to_thread(conn.send, outgoing)
        except Exception as exc:  # noqa: BLE001
            _log.warning("ipc client: %s", exc)
        finally:
            conn.close()

    def _dispatch(self, incoming: Frame) -> Frame:
        rid = incoming.header.request_id
        if incoming.header.ty == MessageType.HEALTH_REQUEST:
            return Frame.new(MessageType.HEALTH_RESPONSE, rid, b"0.1.0")
        if incoming.header.ty == MessageType.AGENT_EXECUTE_REQUEST:
            body = json.loads(incoming.payload.decode() or "{}")
            result = self._container.agent_executor.run(
                ExecuteAgentCommand(
                    body.get("agent_id", "default"),
                    body.get("prompt", ""),
                    body.get("retrieve", False),
                )
            )
            return Frame.new(
                MessageType.AGENT_EXECUTE_RESPONSE,
                rid,
                json.dumps({"execution_id": result.execution_id, "text": result.text}).encode(),
            )
        if incoming.header.ty == MessageType.WORKFLOW_EXECUTE_REQUEST:
            body = json.loads(incoming.payload.decode() or "{}")
            result = self._container.workflow_executor.run(
                ExecuteWorkflowCommand(body.get("prompt", ""))
            )
            return Frame.new(
                MessageType.WORKFLOW_EXECUTE_RESPONSE,
                rid,
                json.dumps({"text": result.text, "steps": result.steps}).encode(),
            )
        return Frame.new(MessageType.ERROR, rid, b"unimplemented")


def run() -> None:
    container = AppContainer.build()
    setup_logging(container.settings.log_level)
    asyncio.run(Application(container).serve())
