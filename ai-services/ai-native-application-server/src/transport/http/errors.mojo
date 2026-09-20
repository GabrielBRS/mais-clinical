from .json import json_escape
from .response import HTTPResponse


def error_json(code: String, message: String) -> String:
    return (
        "{\"error\":\""
        + json_escape(code)
        + "\",\"message\":\""
        + json_escape(message)
        + "\"}"
    )


def response_from_raised(message: String) -> HTTPResponse:
    if message.startswith("not_found"):
        return HTTPResponse.json(404, error_json("not_found", message))
    if message.startswith("invalid_argument"):
        return HTTPResponse.json(400, error_json("invalid_argument", message))
    if message.startswith("unavailable"):
        return HTTPResponse.json(503, error_json("unavailable", message))
    return HTTPResponse.json(500, error_json("internal", message))
