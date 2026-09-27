# AI Native Application Server

Plataforma que unifica backend tradicional e runtime agentic em um único
produto. Rust é o Application Server: único ingress, proprietário da API,
segurança, regras de negócio, casos de uso, persistência e integrações de dados.
O Python em `ai-agent-contract` define agentes, nós, grafos, orquestração, RAG,
retrieval, tool harness e adapters. O Mojo em `ai-agent-runtime` é o runtime
agentic interno: embute CPython, carrega e mantém esses objetos em memória e os
executa sem subprocessos.

Todo projeto inclui os dois processos, mas nem todo fluxo usa Mojo. Um caso de
uso tradicional termina integralmente em Rust. Um caso de uso agentic decide
explicitamente invocar o runtime Mojo e continua sendo proprietário da resposta
ao cliente.

```text
fluxo tradicional: Cliente -> Rust -> dados/integrações -> Rust -> Cliente
fluxo agentic:     Cliente -> Rust -> Mojo runtime -> contrato Python -> Mojo -> Rust -> Cliente
```

É proibido publicar Mojo como API de cliente. HTTP/gRPC/IPC do runtime Mojo são
contratos east-west internos e devem existir somente na rede privada do produto.

```text
.
├── ai-native-application-server/   # projeto principal: mesmo nome da raiz
│   ├── Cargo.toml
│   └── src/                        # somente o Application Server Rust
├── ai-agent-runtime/               # Mojo: agentd, HTTP interno e loaders
│   └── src/contracts/              # espelho 1:1 dos módulos Python
├── ai-agent-contract/              # Python: definições agentic
│   └── src/ai_orchestrator/
├── builds/                         # artefatos movidos por deploy.py
├── deploy.py                       # build Linux e stage em builds/
├── docker-compose.yml
├── docs/
└── .env.example                    # ambiente compartilhado
```

Veja [a fronteira Rust/Mojo](docs/architecture/runtime-boundary.md),
[a ADR da decisão](docs/adr/0002-rust-ingress-mojo-agent-runtime.md) e
[o registro de migração](MIGRATION_ANALYSIS.md).

## Application Server Rust

O runtime inicial fornece configuração, tracing, health/readiness, shutdown
gracioso, geração dos contratos Protobuf, um fluxo CRUD tradicional e a porta
interna `AgentRuntime` com adapter HTTP para o runtime Mojo.

```bash
cargo test --manifest-path ai-native-application-server/Cargo.toml
cargo run --manifest-path ai-native-application-server/Cargo.toml
curl -s http://127.0.0.1:8080/health/ready
```

Imagem da fase atual:

```bash
docker build -f Dockerfile -t orzyon/ai-native-runtime:0.1.0 .
```

Os dois processos sobem juntos com Compose. Apenas a porta Rust `8080` é
publicada; a porta Mojo `8090` existe somente na rede Docker:

```bash
just compose-up
```

## AI Agent Runtime Mojo + contrato Python

O processo Mojo ocupa somente `ai-agent-runtime/`. Ele configura o CPython
embutido, importa todos os módulos de `ai-agent-contract`, mantém os respectivos
`PythonObject` em um registro de processo, constrói o `AppContainer` e oferece
health e execução em uma interface HTTP privada. Agentes, graph, use cases e
adapters são definidos em `ai-agent-contract/src/ai_orchestrator/`.

```text
ai-agent-runtime/src/main.mojo
  └─ host.AgentRuntimeHost
       ├─ private HTTP/TCP
       └─ contracts.PythonContractRegistry
            ├─ 1 loader Mojo por módulo Python
            └─ Python.import_module("ai_orchestrator...")
```

Requer Pixi. A versão do Mojo é fixada pelo `pixi.lock`.

```bash
pixi install --manifest-path ai-agent-runtime/pixi.toml --locked
pixi run --manifest-path ai-agent-runtime/pixi.toml test
pixi run --manifest-path ai-agent-runtime/pixi.toml build
```

O ambiente define `MOJO_PYTHON`, `MOJO_PYTHON_LIBRARY` e
`AOR_CONTRACT_ROOT`. O contrato Python não é código legado: é a fonte de
verdade que o Mojo carrega. `Python.import_module()` acontece no startup; ele
não transforma automaticamente bytecode Python em código nativo Mojo. Kernels
que precisarem de aceleração devem ter implementação Mojo nativa explícita.

```bash
uv run --frozen python -m pytest
```

## Interface do monorepo

O `justfile` combina as validações Rust, Mojo e Python:

```bash
just format
just lint
just test
just build
just run
just compose-up
```

No Linux, `deploy.py` compila o projeto principal (`cargo build --release`) e o
runtime Mojo (`pixi run build`) dentro de cada pasta e move os binários para
`builds/`:

```bash
python3 deploy.py
```

```text
builds/ai-native-application-server/ai-native-runtime
builds/ai-agent-runtime/agentd
```
