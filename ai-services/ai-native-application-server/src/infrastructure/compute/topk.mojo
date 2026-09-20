struct ScoredText(Copyable):
    var score: Float64
    var text: String

    def __init__(out self, score: Float64, var text: String):
        self.score = score
        self.text = text^


def top_k(mut scored: List[ScoredText], k: Int) -> List[String]:
    var n = len(scored)
    var i = 0
    while i < n:
        var best = i
        var j = i + 1
        while j < n:
            if scored[j].score > scored[best].score:
                best = j
            j += 1
        if best != i:
            var tmp = scored[i].copy()
            scored[i] = scored[best].copy()
            scored[best] = tmp^
        i += 1
    var limit = k
    if limit < 1:
        limit = 1
    if limit > n:
        limit = n
    var out = List[String]()
    var t = 0
    while t < limit:
        out.append(scored[t].text.copy())
        t += 1
    return out^
