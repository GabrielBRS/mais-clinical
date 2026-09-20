from pydantic import BaseModel


class ExecuteAgentRequest(BaseModel):
    agent_id: str = "default"
    prompt: str
    retrieve: bool = False
