from __future__ import annotations


class AgentError(Exception):
    pass


class AgentNotFound(AgentError):
    pass
