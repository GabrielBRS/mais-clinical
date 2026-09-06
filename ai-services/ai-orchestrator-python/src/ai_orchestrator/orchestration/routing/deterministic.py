def pick(agent_id: str, available: list[str]) -> str:
    return agent_id if agent_id in available else available[0]
