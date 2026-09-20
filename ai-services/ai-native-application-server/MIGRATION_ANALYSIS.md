# Registro da migração Rust + Mojo

A afirmação anterior de uma migração Mojo concluída não correspondia à árvore
rastreada: Python e Mojo ainda implementam várias das mesmas responsabilidades.
A migração incremental agora segue a fronteira arquitetural correta:

- Rust é o backend completo e o único ingress público;
- Mojo é o runtime agentic interno, não apenas um compute engine;
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
- adapter HTTP privado e fluxo testado Rust -> Mojo -> Rust;
- Dockerfile multi-stage do runtime Rust;
- Compose com ambos os processos e somente a porta Rust publicada;
- comandos Cargo, Pixi e Just para validação;
- configuração de rust-analyzer e Mojo no editor.

Rust já controla as rotas públicas de agent e workflow, mas a implementação
agentic ainda é o baseline Mojo. Agent, workflow e RAG pertencem ao futuro
runtime agentic Mojo. O entrypoint `src/main.mojo` e o pacote Python continuam
como baselines transitórios.

## Estado do baseline Mojo

Após recriar o ambiente `.pixi` pelo `pixi.lock`, os testes Mojo e o build
voltaram a funcionar. O transport gRPC Mojo segue como placeholder; HTTP e
ACE1 continuam sendo transports funcionais apenas do baseline.

Adapters Python de vendors que apenas lançam erro ainda existem e não devem ser
tratados como integrações funcionais. Serão substituídos antes da remoção do
baseline.

## Próxima fatia

1. Criar o processo `mojo-agent-runtime` com health/readiness exclusivamente
   internos e sem porta publicada no host.
2. Migrar para ele agentes, grafo, nós, orchestration, workflow, RAG, retrieval,
   tool harness, inferência e kernels.
3. Implementar o adapter Rust da porta `AgentRuntime`, isolando o transporte.
4. Criar um caso de uso Rust agentic explícito e validar o fluxo
   Rust -> Mojo -> Rust, incluindo indisponibilidade, timeout e retry.
5. Confirmar que um caso de uso tradicional continua funcionando sem chamar
   Mojo e sem depender da readiness dele.
