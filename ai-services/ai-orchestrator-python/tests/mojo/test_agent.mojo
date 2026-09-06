from adapters.local.llm import LocalLlm
from adapters.local.vector import InMemoryVector
from app.application import make_application
from app.config import Settings
from domain.message import Message
from domain.model import GenerationConfig
from std.testing import assert_equal, assert_true, TestSuite
from tools.registry import ToolRegistry


def test_local_generate() raises:
    var llm = LocalLlm()
    var messages = List[Message]()
    messages.append(Message.user("ping"))
    assert_equal(
        llm.generate(messages, GenerationConfig.default()), "[local] ping"
    )


def test_execute_default_agent() raises:
    var app = make_application(Settings.default())
    var result = app.execute_agent("default", "hello")
    assert_equal(result.text, "[local] hello")
    assert_true(result.execution_id.startswith("exe-"))


def test_execute_agent_with_retrieval() raises:
    var app = make_application(Settings.default())
    var result = app.execute_agent("default", "what is ACE1", True)
    assert_true(result.text.startswith("[local]"))
    assert_true(len(result.context) > 0)


def test_execute_workflow() raises:
    var app = make_application(Settings.default())
    var result = app.execute_workflow("hi")
    assert_equal(len(result.steps), 2)
    assert_equal(result.steps[0], "retrieve")
    assert_equal(result.steps[1], "generate")
    assert_true(result.text.startswith("[local]"))


def test_default_vector_indexes_corpus() raises:
    var store = InMemoryVector.with_default_corpus()
    var hits = store.search("ACE1", 1)
    assert_equal(len(hits), 1)
    assert_true(hits[0].find("ACE1") >= 0)


def test_echo_tool() raises:
    var tools = ToolRegistry()
    var echo = tools.execute("echo", "hi")
    assert_true(echo.ok)
    assert_equal(echo.output, "hi")
    var unknown = tools.execute("missing", "")
    assert_true(not unknown.ok)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
