"""Grafo de dependências.

Aqui — e só aqui — ports viram adapters concretos. HTTP, gRPC e IPC recebem
este objeto; use cases recebem ports.
"""

from __future__ import annotations

from dataclasses import dataclass

from ai_orchestrator.adapter.memory.redis import RedisMemory
from ai_orchestrator.adapter.messaging.nats import NatsMessaging
from ai_orchestrator.adapter.rpc.grpc import InferenceClient, RetrievalClient
from ai_orchestrator.adapter.vector.milvus import MilvusVector
from ai_orchestrator.bootstrap.dependencies import default_agents, default_graph, llm, storage
from ai_orchestrator.config.settings import Settings, get_settings
from ai_orchestrator.orchestration.executor import AgentExecutor, WorkflowExecutor
from ai_orchestrator.usecase.execute_agent import ExecuteAgentUseCase
from ai_orchestrator.usecase.execute_workflow import ExecuteWorkflowUseCase
from ai_orchestrator.usecase.generate_response import GenerateResponseUseCase
from ai_orchestrator.usecase.retrieve_context import RetrieveContextUseCase


@dataclass(slots=True)
class AppContainer:
    settings: Settings
    llm: object
    memory: RedisMemory
    messaging: NatsMessaging
    storage: object
    vector: MilvusVector
    inference: InferenceClient
    retrieval: RetrievalClient
    agent_executor: AgentExecutor
    workflow_executor: WorkflowExecutor

    @classmethod
    def build(cls, settings: Settings | None = None) -> AppContainer:
        resolved = settings or get_settings()
        wired_llm = llm(resolved)
        wired_vector = MilvusVector()
        wired_vector.index(
            [
                "ACE1 is the IPC framing used by the three engines.",
                "The orchestrator routes agents, workflows and tools.",
            ]
        )
        agents = default_agents()
        generate = GenerateResponseUseCase(wired_llm)
        retrieve = RetrieveContextUseCase(wired_vector)
        return cls(
            settings=resolved,
            llm=wired_llm,
            memory=RedisMemory(),
            messaging=NatsMessaging(),
            storage=storage(resolved),
            vector=wired_vector,
            inference=InferenceClient(resolved.compute_ipc_path),
            retrieval=RetrievalClient(resolved.data_ipc_path),
            agent_executor=AgentExecutor(ExecuteAgentUseCase(agents, wired_llm, wired_vector)),
            workflow_executor=WorkflowExecutor(
                ExecuteWorkflowUseCase(default_graph(), generate, retrieve)
            ),
        )
