# Arquitetura-alvo

O AI Native Application Server é um produto com dois processos obrigatórios e
papéis diferentes. Rust é o Application Server completo e o único ingress.
Python define o contrato agentic; Mojo carrega, conserva e executa esses objetos
internamente.

```text
Cliente
  -> Rust transport
      -> autenticação, validação e use case
          -> fluxo tradicional -> ports/adapters/dados -> resposta
          -> fluxo agentic -> AgentRuntime port
              -> Mojo runtime -> PythonContractRegistry -> Python AppContainer
                  -> agent -> graph/nodes/tools -> RAG/retrieval/inference
              -> Mojo retorna resultado interno
          -> Rust monta a resposta pública
```

Não existe caminho Cliente -> Mojo. O transporte Rust/Mojo é um detalhe de
adapter e pode mudar entre REST, gRPC, socket ou IPC sem alterar o use case.

Não há domínio agentic duplicado em Mojo. `ai-agent-runtime` contém runtime,
loaders homólogos, cache dos objetos, interop e transporte privado;
`ai-agent-contract/src/ai_orchestrator` é a fonte de verdade das definições.
