from pydantic import BaseModel


class ExecuteAgentResponse(BaseModel):
    execution_id: str
    text: str
    context: list[str]
