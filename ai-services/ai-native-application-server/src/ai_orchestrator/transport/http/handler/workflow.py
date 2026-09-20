from fastapi import APIRouter, Request

from ai_orchestrator.usecase.execute_workflow import ExecuteWorkflowCommand
from ai_orchestrator.transport.http.request.workflow import ExecuteWorkflowRequest
from ai_orchestrator.transport.http.response.workflow import ExecuteWorkflowResponse

router = APIRouter()


@router.post("/execute", response_model=ExecuteWorkflowResponse)
async def execute_workflow(body: ExecuteWorkflowRequest, request: Request) -> ExecuteWorkflowResponse:
    container = request.app.state.container
    result = container.workflow_executor.run(ExecuteWorkflowCommand(body.prompt))
    return ExecuteWorkflowResponse(text=result.text, steps=result.steps)
