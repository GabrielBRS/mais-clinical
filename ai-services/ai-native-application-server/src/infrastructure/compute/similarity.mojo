def dot(a: List[Float64], b: List[Float64]) -> Float64:
    var n = min(len(a), len(b))
    var score = Float64(0.0)
    var i = 0
    while i < n:
        score = score + a[i] * b[i]
        i += 1
    return score
