from ai_orchestrator.adapter.vector.milvus import MilvusVector


def test_index_and_search() -> None:
    store = MilvusVector()
    store.index(["ACE1 framing", "unrelated cooking recipe"])
    hits = store.search("ACE1", top_k=1)
    assert hits[0] == "ACE1 framing"
