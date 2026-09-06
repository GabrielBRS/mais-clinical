from fastapi import APIRouter

from ai_orchestrator.transport.http.handler import workflow

router = APIRouter()
router.include_router(workflow.router)
