def slice_str(text: String, start: Int, end: Int) -> String:
    var raw = text.as_bytes()
    var n = len(raw)
    var i = start
    if i < 0:
        i = 0
    var last = end
    if last > n:
        last = n
    var out = String()
    while i < last:
        out += String(chr(Int(raw[i])))
        i += 1
    return out^


def skip_ws(text: String, start: Int) -> Int:
    var raw = text.as_bytes()
    var i = start
    var n = len(raw)
    while i < n:
        var b = Int(raw[i])
        if b != 32 and b != 9 and b != 10 and b != 13:
            return i
        i += 1
    return i
