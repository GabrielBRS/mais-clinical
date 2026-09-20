from infrastructure.local.vector import InMemoryVector


def main() raises:
    var store = InMemoryVector()
    var documents = List[String]()
    for i in range(32):
        documents.append("ACE1 framing " + String(i))
    _ = store.index(documents^)
    var hits = List[String]()
    for i in range(1000):
        _ = i
        hits = store.search("ACE1", 4)
    print("1000 retrievals", len(hits))
