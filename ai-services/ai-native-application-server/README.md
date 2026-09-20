# ai-orchestrator

Servidor de aplicações agentic implementado integralmente em Mojo. O binário
`agentd` é dono do processo, do domínio, dos workflows, do RAG local e dos
transports. Não existe runtime auxiliar nem bridge de outra linguagem.

```text
main.mojo
  └─ bootstrap.Application
       └─ Service (poll POSIX)
            ├─ HTTP/TCP → endpoints → handlers → use cases
            └─ IPC/Unix → ACE1 → use cases
```

## Requisitos e execução

Requer Pixi. A versão do Mojo é fixada pelo `pixi.lock`.

```bash
pixi install --locked
pixi run test
pixi run smoke
pixi run build
pixi run run
```

O processo atende simultaneamente:

- HTTP em `0.0.0.0:8080`;
- IPC ACE1 em `/tmp/ai-orchestrator.sock`.

Configuração por variáveis `AOR_*`; veja `.env.example`.

## HTTP

```bash
curl -s http://127.0.0.1:8080/health/ready
curl -s -X POST http://127.0.0.1:8080/agents/execute \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"hello mojo","retrieve":true}'
curl -s -X POST http://127.0.0.1:8080/workflows/execute \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"ACE1"}'
```

## Exemplos e benchmarks

```bash
pixi run example-agent
pixi run example-workflow
pixi run example-http
pixi run example-ipc   # requer agentd em execução
pixi run bench
```

Testes de bind de sockets são separados porque ambientes isolados podem
bloquear rede local:

```bash
pixi run test-network
```

O adapter gRPC antigo foi retirado. Ele expunha somente health e dependia de
protobuf; os contratos equivalentes são HTTP health e ACE1 health.
