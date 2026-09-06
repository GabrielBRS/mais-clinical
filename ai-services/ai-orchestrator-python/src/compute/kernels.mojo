"""Local embedding kernel. Parity with Python `_hash_embed` (FNV-1a, dim 32)."""


def hash_embed(text: String, dim: Int = 32) -> List[Float64]:
    var values = List[Float64](length=dim, fill=Float64(0.0))
    var raw = List[UInt8]()
    var src = text.as_bytes()
    var s = 0
    while s < len(src):
        raw.append(UInt8(Int(src[s])))
        s += 1
    var i = 0
    var n = len(raw)
    while i < n:
        while i < n and raw[i] == 32:
            i += 1
        if i >= n:
            break
        var start = i
        while i < n and raw[i] != 32:
            i += 1
        _accumulate_token(values, raw, start, i, dim)
    var norm = Float64(0.0)
    var j = 0
    while j < dim:
        norm = norm + values[j] * values[j]
        j += 1
    if norm > Float64(0.0):
        var scale = Float64(1.0) / sqrt(norm)
        j = 0
        while j < dim:
            values[j] = values[j] * scale
            j += 1
    return values^


def sqrt(value: Float64) -> Float64:
    if value <= Float64(0.0):
        return Float64(0.0)
    var guess = value
    var k = 0
    while k < 16:
        guess = Float64(0.5) * (guess + value / guess)
        k += 1
    return guess


def _accumulate_token(
    mut values: List[Float64],
    raw: List[UInt8],
    start: Int,
    end: Int,
    dim: Int,
):
    var h: UInt64 = 1469598103934665603
    var i = start
    while i < end:
        var b = raw[i]
        if b >= 65 and b <= 90:
            b = b + 32
        h ^= UInt64(Int(b))
        h = h * UInt64(1099511628211)
        i += 1
    var idx = Int(h % UInt64(dim))
    values[idx] = values[idx] + Float64(1.0)
