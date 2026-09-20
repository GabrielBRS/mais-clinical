# AI Native Application Server

Plataforma que unifica backend tradicional e runtime agentic em um único
produto. Rust é o Application Server: único ingress, proprietário da API,
segurança, regras de negócio, casos de uso, persistência e integrações de dados.
Mojo é um runtime agentic exclusivamente interno: agentes, nós, grafos,
orquestração, RAG, retrieval, tool harness, inferência e kernels.

Todo projeto inclui os dois processos, mas nem todo fluxo usa Mojo. Um caso de
uso tradicional termina integralmente em Rust. Um caso de uso agentic decide
explicitamente invocar o runtime Mojo e continua sendo proprietário da resposta
ao cliente.

```text
fluxo tradicional: Cliente -> Rust -> dados/integrações -> Rust -> Cliente
fluxo agentic:     Cliente -> Rust use case -> Mojo agent runtime -> Rust -> Cliente
```

É proibido publicar Mojo como API de cliente. HTTP/gRPC/IPC do runtime Mojo são
contratos east-west internos e devem existir somente na rede privada do produto.

Veja [a fronteira Rust/Mojo](docs/architecture/runtime-boundary.md),
[a ADR da decisão](docs/adr/0002-rust-ingress-mojo-agent-runtime.md) e
[o registro de migração](MIGRATION_ANALYSIS.md).

## Runtime Rust

O runtime inicial fornece configuração, tracing, health/readiness, shutdown
gracioso, geração dos contratos Protobuf, um fluxo CRUD tradicional e a porta
interna `AgentRuntime` com adapter HTTP para o baseline Mojo.

```bash
cargo test --workspace
cargo run -p ai-native-runtime
curl -s http://127.0.0.1:8080/health/ready
```

Imagem da fase atual:

```bash
docker build -f runtime-rust/Dockerfile \
  -t orzyon/ai-native-runtime:0.1.0 .
```

Os dois processos sobem juntos com Compose. Apenas a porta Rust `8080` é
publicada; a porta Mojo `8090` existe somente na rede Docker:

```bash
pixi run just compose-up
```

## Baseline Mojo interno

A aplicação Mojo existente ainda contém transports públicos da implementação
anterior. Eles existem somente para testes de paridade e serão reduzidos ao
contrato interno do runtime agentic. Não devem receber tráfego de clientes.

```text
main.mojo
  └─ bootstrap.Application
       └─ Service (baseline transitório)
            ├─ HTTP/TCP
            └─ IPC/Unix ACE1
```

Requer Pixi. A versão do Mojo é fixada pelo `pixi.lock`.

```bash
pixi install --locked
pixi run test
pixi run smoke
pixi run build
```

Exemplos e benchmarks do baseline:

```bash
pixi run example-agent
pixi run example-workflow
pixi run example-http
pixi run example-ipc
pixi run bench
```

O contrato final do Mojo será interno e invocado apenas pelo adapter Rust da
porta `AgentRuntime`. Não haverá rota pública que faça proxy transparente para
Mojo; todo uso agentic começa em um caso de uso Rust autenticado e validado.

## Baseline Python

O pacote `src/ai_orchestrator/` permanece somente para testes de paridade. Use
o interpretador do ambiente, evitando launchers de virtualenv realocados:

```bash
uv run --frozen python -m pytest
```

## Interface do monorepo

O `justfile` combina as validações Rust, Mojo e Python enquanto a migração está
em andamento. Após `pixi install --locked`, use `pixi run just` diretamente ou
ative o ambiente Pixi para chamar `just` sem prefixo:

```bash
pixi run just format
pixi run just lint
pixi run just test
pixi run just build
pixi run just run
pixi run just benchmark
pixi run just compose-up
```
