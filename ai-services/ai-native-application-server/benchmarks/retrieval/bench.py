from ai_orchestrator.adapter.vector.milvus import MilvusVector


def main() -> None:
    store = MilvusVector()
    store.index(["ACE1 framing"] * 32)
    store.search("ACE1", top_k=4)


if __name__ == "__main__":
    main()
