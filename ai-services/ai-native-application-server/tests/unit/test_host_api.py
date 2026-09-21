from __future__ import annotations

import json

from ai_orchestrator.bootstrap.composition_root import AppContainer
from ai_orchestrator.host_api import execute_agent, execute_workflow, health, install_container


def install_python_runtime() -> None:
    install_container(AppContainer.build())


def body(response: dict[str, str]) -> dict:
    return json.loads(response["body"])


def test_host_health_uses_installed_composition_root() -> None:
    install_python_runtime()
    response = health()
    assert response["status"] == "200"
    assert body(response)["runtime"] == "ai-orchestrator-python"


def test_host_agent_executes_real_python_use_case() -> None:
    install_python_runtime()
    response = execute_agent('{"agent_id":"default","prompt":"hello"}')
    assert response["status"] == "200"
    assert body(response)["text"] == "[local] hello"
    assert body(response)["steps"] == ["python:ExecuteAgentUseCase"]


def test_host_workflow_executes_real_python_graph() -> None:
    install_python_runtime()
    response = execute_workflow('{"prompt":"orchestrator"}')
    assert response["status"] == "200"
    assert body(response)["steps"] == [
        "retrieve",
        "generate",
        "python:ExecuteWorkflowUseCase",
    ]
