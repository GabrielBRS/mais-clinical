struct Tokenizer(Copyable):
    """Whitespace tokenizer. Native Mojo; no Hugging Face."""

    var _marker: Bool

    def __init__(out self):
        self._marker = True

    def encode(self, text: String) -> List[String]:
        var out = List[String]()
        var raw = text.as_bytes()
        var i = 0
        var n = len(raw)
        while i < n:
            while i < n and Int(raw[i]) == 32:
                i += 1
            if i >= n:
                break
            var start = i
            while i < n and Int(raw[i]) != 32:
                i += 1
            var token = String()
            var j = start
            while j < i:
                token += String(chr(Int(raw[j])))
                j += 1
            out.append(token^)
        return out^

    def encode_batch(self, texts: List[String]) -> List[List[String]]:
        var out = List[List[String]]()
        for text in texts:
            out.append(self.encode(text))
        return out^
