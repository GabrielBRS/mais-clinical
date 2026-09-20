def pick_id(agent_id: String, available: List[String]) -> String:
    for item in available:
        if item == agent_id:
            return agent_id
    if len(available) == 0:
        return agent_id
    return available[0].copy()


def pick_semantic(prompt: String, available: List[String]) -> String:
    _ = prompt
    if len(available) == 0:
        return ""
    return available[0].copy()


struct Router(Copyable):
    var _marker: Bool

    def __init__(out self):
        self._marker = True

    def route(
        self, agent_id: String, prompt: String, available: List[String]
    ) -> String:
        if agent_id.byte_length() > 0:
            return pick_id(agent_id, available)
        return pick_semantic(prompt, available)
