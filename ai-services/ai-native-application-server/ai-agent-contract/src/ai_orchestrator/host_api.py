"""Narrow facade called by the embedded CPython runtime in the Mojo host.

This module deliberately exposes JSON-in/JSON-out functions. Mojo owns the
private transport, while the existing Python composition root owns agents,
graphs, use cases, and adapters.
"""

from __future__ import annotations

import json
from typing import Any
from uuid import uuid4

from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.domain.agent import AgentNotFound
from ai_orchestrator.usecase.execute_agent import ExecuteAgentCommand
from ai_orchestrator.usecase.execute_workflow import ExecuteWorkflowCommand


_container: AppContainer | None = None


def install_container(container: AppContainer) -> None:
    """Install the composition root constructed directly by the Mojo host."""

    global _container
    _container = container


def health() -> dict[str, str]:
    container = _require_container()
    return _response(
        200,
        {
            "status": "ok",
            "version": "0.1.0",
            "ready": True,
            "runtime": container.settings.app_name,
        },
    )


def execute_agent(payload: str) -> dict[str, str]:
    try:
        body = _request(payload)
        prompt = str(body.get("prompt", ""))
        if not prompt.strip():
            return _error(400, "invalid_argument", "prompt is required")
        result = _require_container().agent_executor.run(
            ExecuteAgentCommand(
                agent_id=str(body.get("agent_id", "default")),
                prompt=prompt,
                retrieve=bool(body.get("retrieve", False)),
            )
        )
        return _response(
            200,
            {
                "execution_id": result.execution_id,
                "text": result.text,
                "context": result.context,
                "steps": ["python:ExecuteAgentUseCase"],
            },
        )
    except AgentNotFound as error:
        return _error(404, "not_found", str(error))
    except (TypeError, ValueError, json.JSONDecodeError) as error:
        return _error(400, "invalid_argument", str(error))
    except Exception as error:  # noqa: BLE001 - normalized at the process boundary
        return _error(500, "internal", str(error))


def execute_workflow(payload: str) -> dict[str, str]:
    try:
        body = _request(payload)
        prompt = str(body.get("prompt", ""))
        if not prompt.strip():
            return _error(400, "invalid_argument", "prompt is required")
        result = _require_container().workflow_executor.run(ExecuteWorkflowCommand(prompt))
        return _response(
            200,
            {
                "execution_id": f"workflow-{uuid4()}",
                "text": result.text,
                "context": [],
                "steps": [*result.steps, "python:ExecuteWorkflowUseCase"],
            },
        )
    except (TypeError, ValueError, json.JSONDecodeError) as error:
        return _error(400, "invalid_argument", str(error))
    except Exception as error:  # noqa: BLE001 - normalized at the process boundary
        return _error(500, "internal", str(error))


def _require_container() -> AppContainer:
    if _container is None:
        raise RuntimeError("AppContainer was not installed by the Mojo host")
    return _container


def _request(payload: str) -> dict[str, Any]:
    body = json.loads(payload or "{}")
    if not isinstance(body, dict):
        raise TypeError("request body must be a JSON object")
    return body


def _response(status: int, body: dict[str, Any]) -> dict[str, str]:
    return {
        "status": str(status),
        "body": json.dumps(body, ensure_ascii=False, separators=(",", ":")),
    }


def _error(status: int, code: str, message: str) -> dict[str, str]:
    return _response(status, {"error": code, "message": message})
