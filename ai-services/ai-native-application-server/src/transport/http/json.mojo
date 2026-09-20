from .text import skip_ws, slice_str


def json_escape(text: String) -> String:
    var raw = text.as_bytes()
    var out = String()
    var i = 0
    while i < len(raw):
        var b = Int(raw[i])
        if b == 92:
            out += "\\\\"
        elif b == 34:
            out += "\\\""
        elif b == 10:
            out += "\\n"
        elif b == 13:
            out += "\\r"
        elif b == 9:
            out += "\\t"
        else:
            out += String(chr(b))
        i += 1
    return out^


def json_string(text: String) -> String:
    return "\"" + json_escape(text) + "\""


def json_string_list(items: List[String]) -> String:
    var out = String("[")
    var first = True
    for item in items:
        if not first:
            out += ","
        first = False
        out += json_string(item)
    out += "]"
    return out^


def json_field_string(body: String, key: String, default: String = "") -> String:
    var needle = "\"" + key + "\""
    var start = body.find(needle)
    if start < 0:
        return default
    var i = skip_ws(body, start + needle.byte_length())
    if i >= body.byte_length() or Int(body.as_bytes()[i]) != 58:
        return default
    i = skip_ws(body, i + 1)
    if i >= body.byte_length() or Int(body.as_bytes()[i]) != 34:
        return default
    i += 1
    var raw = body.as_bytes()
    var out = String()
    while i < len(raw):
        var b = Int(raw[i])
        if b == 92 and i + 1 < len(raw):
            out += String(chr(Int(raw[i + 1])))
            i += 2
            continue
        if b == 34:
            return out^
        out += String(chr(b))
        i += 1
    return out^


def json_field_bool(body: String, key: String, default: Bool = False) -> Bool:
    var needle = "\"" + key + "\""
    var start = body.find(needle)
    if start < 0:
        return default
    var i = skip_ws(body, start + needle.byte_length())
    if i >= body.byte_length() or Int(body.as_bytes()[i]) != 58:
        return default
    i = skip_ws(body, i + 1)
    var token = slice_str(body, i, i + 5)
    if token.startswith("true"):
        return True
    if token.startswith("false"):
        return False
    return default
