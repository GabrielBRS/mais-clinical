from fastapi import APIRouter

from ai_orchestrator.transport.http.router import agent, health, workflow

api_router = APIRouter()
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(agent.router, prefix="/agents", tags=["agents"])
api_router.include_router(workflow.router, prefix="/workflows", tags=["workflows"])
