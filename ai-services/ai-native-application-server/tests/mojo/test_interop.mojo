from application.graph.runtime import GraphRuntime
from infrastructure.local.embeddings import EmbeddingModel
from infrastructure.local.tokenizer import Tokenizer
from infrastructure.local.training import TrainingRuntime
from infrastructure.local.transformers import TransformersRuntime
from infrastructure.settings import load_settings
from std.testing import assert_equal, assert_true, TestSuite


def test_load_settings_uses_defaults_without_env() raises:
    var settings = load_settings()
    assert_equal(settings.app_name, "ai-orchestrator")
    assert_equal(settings.http_port, 8080)


def test_tokenizer_splits_whitespace() raises:
    var tokenizer = Tokenizer()
    var tokens = tokenizer.encode("Hello Mojo")
    assert_equal(len(tokens), 2)
    assert_equal(tokens[0], "Hello")
    assert_equal(tokens[1], "Mojo")


def test_tokenizer_batch() raises:
    var tokenizer = Tokenizer()
    var texts = List[String]()
    texts.append("Hello Mojo")
    texts.append("one crossing")
    var batches = tokenizer.encode_batch(texts)
    assert_equal(len(batches), 2)
    assert_equal(len(batches[0]), 2)
    assert_equal(len(batches[1]), 2)
    assert_equal(batches[1][0], "one")


def test_local_runtimes_ping() raises:
    var graph = GraphRuntime()
    var transformers = TransformersRuntime()
    var embeddings = EmbeddingModel()
    var training = TrainingRuntime()
    assert_true(graph.ping().find("graph") >= 0)
    assert_true(transformers.ping().find("local") >= 0)
    assert_true(embeddings.ping().find("hash_embed") >= 0)
    assert_true(training.ping().find("local") >= 0)


def test_graph_run_kinds_generate() raises:
    var graph = GraphRuntime()
    var kinds = List[String]()
    kinds.append("generate")
    var turn = graph.run_kinds(kinds, "hello mojo", List[String]())
    assert_equal(turn.text, "[graph] hello mojo")
    assert_equal(len(turn.steps), 1)
    assert_equal(turn.steps[0], "generate")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
