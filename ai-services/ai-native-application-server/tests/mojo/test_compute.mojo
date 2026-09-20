from application.rag.chunker import chunk_text
from application.rag.reranker import rerank
from infrastructure.compute.kernels import hash_embed
from infrastructure.compute.similarity import dot
from infrastructure.compute.topk import ScoredText, top_k
from std.testing import assert_equal, assert_true, TestSuite


def test_hash_embed_dim_and_norm() raises:
    var vec = hash_embed("hello world")
    assert_equal(len(vec), 32)
    var norm = Float64(0.0)
    for value in vec:
        norm = norm + value * value
    assert_true(norm > Float64(0.99))
    assert_true(norm < Float64(1.01))


def test_hash_embed_stable() raises:
    var a = hash_embed("ACE1 framing")
    var b = hash_embed("ACE1 framing")
    assert_equal(len(a), len(b))
    var i = 0
    while i < len(a):
        assert_equal(a[i], b[i])
        i += 1


def test_dot_and_topk() raises:
    var a = List[Float64]()
    a.append(1.0)
    a.append(0.0)
    var b = List[Float64]()
    b.append(0.0)
    b.append(1.0)
    assert_equal(dot(a, a), 1.0)
    assert_equal(dot(a, b), 0.0)
    var scored = List[ScoredText]()
    scored.append(ScoredText(0.1, "low"))
    scored.append(ScoredText(0.9, "high"))
    var picked = top_k(scored, 1)
    assert_equal(picked[0], "high")


def test_chunker() raises:
    var chunks = chunk_text("abcdefghij", 4)
    assert_equal(len(chunks), 3)
    assert_equal(chunks[0], "abcd")


def test_rerank_orders_by_query() raises:
    var docs = List[String]()
    docs.append("unrelated text")
    docs.append("ACE1 is the IPC framing used by the three engines.")
    var ranked = rerank("ACE1 framing", docs, 2)
    assert_equal(len(ranked), 2)
    assert_true(ranked[0].find("ACE1") >= 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
