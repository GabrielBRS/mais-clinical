def chunk_text(text: String, max_chars: Int = 240) -> List[String]:
    var chunks = List[String]()
    if text.byte_length() == 0:
        return chunks^
    if max_chars < 1:
        chunks.append(text.copy())
        return chunks^
    var raw = text.as_bytes()
    var i = 0
    var n = len(raw)
    while i < n:
        var end = i + max_chars
        if end > n:
            end = n
        var piece = String()
        var j = i
        while j < end:
            piece += String(chr(Int(raw[j])))
            j += 1
        chunks.append(piece^)
        i = end
    return chunks^
