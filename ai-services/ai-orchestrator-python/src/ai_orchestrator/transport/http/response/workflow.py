from pydantic import BaseModel


class ExecuteWorkflowResponse(BaseModel):
    text: str
    steps: list[str]
