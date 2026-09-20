# Registro da migração para Mojo

Migração concluída para uma única implementação e um único runtime.

## Resultado

- domínio, agentes, mensagens, estado e erros: Mojo;
- execução de agente e workflow: Mojo;
- grafo, roteamento, RAG, embeddings, similaridade e top-k: Mojo;
- memória local e tool registry: Mojo;
- parser/servidor HTTP: Mojo sobre sockets POSIX;
- framing e servidor IPC ACE1: Mojo sobre sockets Unix POSIX;
- configuração: Mojo via `std.os.getenv`;
- testes, exemplos, smoke test e benchmarks: Mojo.

O entrypoint único é `src/main.mojo`, compilado como `build/agentd`.

## Decisões de readaptação

O antigo transport gRPC possuía apenas health e dependia de um gerador de
protobuf. Ele não foi replicado como placeholder. Health permanece disponível
em `GET /health`, `GET /health/live`, `GET /health/ready` e no tipo ACE1 1/2.

Adapters de vendors que apenas lançavam erro ou não executavam trabalho foram
removidos. Integrações futuras devem entrar como adapters Mojo concretos ou
como serviços externos acessados pelo protocolo ACE1.

## Critérios de aceitação

1. `pixi run test` valida domínio, grafo, agente, compute, IPC e HTTP.
2. `pixi run smoke` atravessa HTTP e ACE1 até os mesmos use cases.
3. `pixi run build` produz o executável `agentd`.
4. `pixi run test-network` valida bind TCP e Unix fora de sandboxes restritos.
5. Nenhum arquivo-fonte executável fora de `.mojo` pertence ao projeto.
