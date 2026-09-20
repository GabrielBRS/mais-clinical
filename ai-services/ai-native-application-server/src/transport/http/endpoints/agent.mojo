from application.application import Application
from application.commands import ExecuteAgentCommand
from application.use_cases.execute_agent import ExecuteAgentUseCase
from domain.execution import ExecutionResult
from transport.http.errors import response_from_raised
from transport.http.json import json_field_bool, json_field_string, json_string
from transport.http.json import json_string_list
from transport.http.request import HTTPRequest
from transport.http.response import HTTPResponse
from transport.http.router import Router


def register_agent_endpoints(mut router: Router):
    router.post("/agents/execute", "agent.execute", handle_agent_execute)


def _result_body(result: ExecutionResult) -> String:
    return (
        "{\"execution_id\":"
        + json_string(result.execution_id)
        + ",\"text\":"
        + json_string(result.text)
        + ",\"context\":"
        + json_string_list(result.context)
        + ",\"steps\":"
        + json_string_list(result.steps)
        + "}"
    )


def handle_agent_execute(
    mut app: Application, request: HTTPRequest
) raises -> HTTPResponse:
    var prompt = json_field_string(request.body, "prompt")
    if prompt.byte_length() == 0:
        return HTTPResponse.json(
            400, "{\"error\":\"invalid_argument\",\"message\":\"prompt obrigatorio\"}"
        )
    var agent_id = json_field_string(request.body, "agent_id", "default")
    var retrieve = json_field_bool(request.body, "retrieve", False)
    var backend = json_field_string(request.body, "backend", "local")
    try:
        var result = ExecuteAgentUseCase.execute(
            app, ExecuteAgentCommand(agent_id^, prompt^, retrieve, backend^)
        )
        return HTTPResponse.json(200, _result_body(result))
    except e:
        return response_from_raised(String(e))
