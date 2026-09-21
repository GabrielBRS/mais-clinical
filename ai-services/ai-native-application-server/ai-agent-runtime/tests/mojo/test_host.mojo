from host.config import HostSettings
from host.interop.python_runtime import (
    execute_agent,
    execute_workflow,
    health,
    initialize_python,
)
from host.runtime import AgentRuntimeHost
from contracts.registry import expected_contract_module_count
from std.testing import TestSuite, assert_equal, assert_true


def test_imports_real_python_composition_root() raises:
    var contracts = initialize_python("../ai-agent-contract")
    assert_equal(contracts.count, expected_contract_module_count())
    var response = health()
    assert_equal(response.status, 200)
    assert_true(response.body.find('"runtime":"ai-orchestrator-python"') >= 0)


def test_executes_python_agent_use_case() raises:
    _ = initialize_python("../ai-agent-contract")
    var response = execute_agent('{"agent_id":"default","prompt":"hello"}')
    assert_equal(response.status, 200)
    assert_true(response.body.find("[local] hello") >= 0)
    assert_true(response.body.find("python:ExecuteAgentUseCase") >= 0)


def test_executes_python_workflow_use_case() raises:
    _ = initialize_python("../ai-agent-contract")
    var response = execute_workflow('{"prompt":"orchestrator"}')
    assert_equal(response.status, 200)
    assert_true(response.body.find("retrieve") >= 0)
    assert_true(response.body.find("python:ExecuteWorkflowUseCase") >= 0)


def test_private_http_dispatches_to_python() raises:
    _ = initialize_python("../ai-agent-contract")
    var runtime = AgentRuntimeHost(
        HostSettings("127.0.0.1", UInt16(0), "../ai-agent-contract")
    )
    var response = runtime.handle(
        "POST /agents/execute HTTP/1.1\r\n"
        + "Content-Length: 35\r\n\r\n"
        + '{"agent_id":"default","prompt":"hi"}'
    )
    assert_equal(response.status, 200)
    assert_true(response.body.find("python:ExecuteAgentUseCase") >= 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
