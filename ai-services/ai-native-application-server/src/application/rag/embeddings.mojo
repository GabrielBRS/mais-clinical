from infrastructure.compute.kernels import hash_embed


def embed_query(query: String) -> List[Float64]:
    return hash_embed(query)
