# Registro da migração Rust + Mojo

A implementação Mojo anterior duplicava a arquitetura hexagonal Python e nunca
importava `ai_orchestrator`. A estrutura foi corrigida para a fronteira real:

- Rust é o backend completo e o único ingress público;
- Mojo é o runtime agentic interno;
- Python `ai_orchestrator` continua sendo o contrato e a fonte das definições agentic;
- um use case Rust pode ou não invocar Mojo;
- clientes nunca acessam Mojo diretamente.

## Fase 1 — infraestrutura base

Entregue nesta fase:

- workspace Cargo e crate `ai-native-runtime`;
- configuração `AOR_*` validada;
- logs JSON, tracing HTTP e erros tipados;
- health, liveness e readiness;
- shutdown gracioso por SIGINT/SIGTERM;
- geração Rust de todos os contratos Protobuf;
- contrato de health compartilhado, sem símbolos Protobuf duplicados;
- porta Rust interna `AgentRuntime`, injetada somente em casos de uso agentic;
- CRUD Rust de referência que não chama Mojo;
- adapter HTTP privado e fluxo Rust -> Mojo -> Python -> Mojo -> Rust;
- Dockerfile multi-stage do runtime Rust;
- Compose com ambos os processos e somente a porta Rust publicada;
- separação física em `src/` (Rust), `ai-agent-runtime/` (Mojo) e
  `ai-agent-contract/` (Python);
- loaders Mojo 1:1 gerados para os 202 módulos Python e registro carregado no
  startup;
- comandos Cargo, Pixi e Just para validação;
- configuração de rust-analyzer e Mojo no editor.

Rust controla as rotas públicas de agent e workflow. O runtime Mojo sob
`ai-agent-runtime/src/host` importa o `AppContainer` real e chama `ExecuteAgentUseCase` e
`ExecuteWorkflowUseCase` do Python. Não existem mais `struct Agent`, graph ou
RAG duplicados em Mojo.

## Estado do host Mojo/Python

O ambiente Pixi fornece Python 3.13, Mojo e o pacote Python editável. O binário
`agentd` liga `libpython3.13`, usa `MOJO_PYTHON`, `MOJO_PYTHON_LIBRARY` e
`AOR_CONTRACT_ROOT`, e
expõe somente HTTP interno para o adapter Rust.

Adapters Python de vendors que apenas lançam erro ainda existem e não devem ser
tratados como integrações funcionais. Serão substituídos antes da remoção do
baseline.

## Próxima fatia

1. Evoluir o contrato interno para gRPC/IPC se a medição justificar.
2. Implementar autenticação, persistência e domínio tradicionais no Rust.
3. Completar adapters Python hoje representados por implementações locais.
4. Adicionar timeout, retry e circuit breaker no adapter Rust sem afetar CRUD.
