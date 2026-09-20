from fastapi import APIRouter

from ai_orchestrator.transport.http.handler import agent

router = APIRouter()
router.include_router(agent.router)
