from fastapi import APIRouter, Request

from ai_orchestrator.usecase.execute_agent import ExecuteAgentCommand
from ai_orchestrator.transport.http.request.agent import ExecuteAgentRequest
from ai_orchestrator.transport.http.response.agent import ExecuteAgentResponse

router = APIRouter()


@router.post("/execute", response_model=ExecuteAgentResponse)
async def execute_agent(body: ExecuteAgentRequest, request: Request) -> ExecuteAgentResponse:
    container = request.app.state.container
    result = container.agent_executor.run(
        ExecuteAgentCommand(body.agent_id, body.prompt, body.retrieve)
    )
    return ExecuteAgentResponse(
        execution_id=result.execution_id,
        text=result.text,
        context=result.context,
    )
