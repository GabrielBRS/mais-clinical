from pydantic import BaseModel


class ExecuteWorkflowRequest(BaseModel):
    prompt: str
