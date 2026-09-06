from app.application import VERSION, make_application
from ports.llm_provider import LLMProvider
from ports.vector_store import VectorStore
from app.config import Settings
from app.lifecycle import Lifecycle
from domain.errors import OrchestratorError
from domain.message import Message, Role
from domain.state import ExecutionStatus, next_status
from domain.status import Status, StatusCode
from std.testing import assert_equal, assert_raises, assert_true, TestSuite


def test_status_ok() raises:
    var status = Status.ok()
    assert_true(status.is_ok())
    assert_equal(status.code, StatusCode.ok)


def test_execution_status_machine() raises:
    assert_equal(
        next_status(ExecutionStatus.pending, "start"), ExecutionStatus.running
    )
    assert_equal(
        next_status(ExecutionStatus.running, "ok"), ExecutionStatus.succeeded
    )
    assert_equal(
        next_status(ExecutionStatus.running, "fail"), ExecutionStatus.failed
    )


def test_message_factories() raises:
    var user = Message.user("hello")
    assert_equal(user.role, Role.user)
    assert_equal(user.text, "hello")
    assert_equal(Message.system("sys").role, Role.system)


def test_lifecycle() raises:
    var life = Lifecycle()
    assert_true(not life.is_running())
    life.start()
    assert_true(life.is_running())
    life.stop()
    assert_true(not life.is_running())


def test_settings_defaults() raises:
    var settings = Settings.default()
    assert_equal(settings.app_name, "ai-orchestrator")
    assert_equal(settings.http_port, 8080)
    assert_equal(settings.grpc_port, 50051)
    assert_equal(settings.ipc_path, "/tmp/ai-orchestrator-python.sock")


def test_application_health() raises:
    var app = make_application(Settings.default())
    var health = app.health()
    assert_equal(health.version, VERSION)
    assert_true(not health.ready)
    assert_true(health.status.is_ok())


def test_orchestrator_error_writable() raises:
    var err = OrchestratorError(StatusCode.not_found, "missing")
    assert_equal(err.code, StatusCode.not_found)
    assert_equal(String(err), "not_found: missing")


def test_unknown_agent() raises:
    var app = make_application(Settings.default())
    with assert_raises(contains="nao encontrado"):
        _ = app.execute_agent("missing", "hello")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
