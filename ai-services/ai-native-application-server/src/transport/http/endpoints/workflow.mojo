from application.application import Application
from application.commands import ExecuteWorkflowCommand
from application.use_cases.execute_workflow import ExecuteWorkflowUseCase
from domain.execution import ExecutionResult
from transport.http.errors import response_from_raised
from transport.http.json import json_field_string, json_string, json_string_list
from transport.http.request import HTTPRequest
from transport.http.response import HTTPResponse
from transport.http.router import Router


def register_workflow_endpoints(mut router: Router):
    router.post("/workflows/execute", "workflow.execute", handle_workflow_execute)


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


def handle_workflow_execute(
    mut app: Application, request: HTTPRequest
) raises -> HTTPResponse:
    var prompt = json_field_string(request.body, "prompt")
    if prompt.byte_length() == 0:
        return HTTPResponse.json(
            400, "{\"error\":\"invalid_argument\",\"message\":\"prompt obrigatorio\"}"
        )
    try:
        var result = ExecuteWorkflowUseCase.execute(
            app, ExecuteWorkflowCommand(prompt^)
        )
        return HTTPResponse.json(200, _result_body(result))
    except e:
        return response_from_raised(String(e))
