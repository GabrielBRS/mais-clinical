from infrastructure.compute.kernels import hash_embed
from infrastructure.compute.similarity import dot
from infrastructure.compute.topk import ScoredText, top_k


def rerank(query: String, documents: List[String], k: Int = 8) -> List[String]:
    var q = hash_embed(query)
    var scored = List[ScoredText]()
    for text in documents:
        scored.append(ScoredText(dot(q, hash_embed(text)), text.copy()))
    return top_k(scored, k)
