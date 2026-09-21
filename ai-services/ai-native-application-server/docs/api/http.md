# HTTP público

Somente o processo Rust serve HTTP público. Na fase atual estão disponíveis:

- `GET /health`, `/health/live` e `/health/ready`;
- `GET /records`, `GET /records/{id}` e `POST /records`, como fluxo CRUD
  tradicional que nunca chama Mojo;
- `POST /agents/execute`, como caso de uso Rust que valida e invoca a porta
  interna `AgentRuntime`;
- `POST /workflows/execute`, com a mesma fronteira
  Rust -> Mojo -> Python -> Mojo -> Rust.

```bash
curl -s http://127.0.0.1:8080/health/ready
curl -s -X POST http://127.0.0.1:8080/records \
  -H 'Content-Type: application/json' \
  -d '{"title":"paciente"}'
curl -s -X POST http://127.0.0.1:8080/agents/execute \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"resuma o prontuario"}'
```

As duas últimas rotas são públicas somente no Rust. O adapter Rust chama as
rotas homônimas do runtime Mojo pela rede interna. O runtime usa os objetos já
carregados do contrato Python `ai_orchestrator`. Não existe proxy público
genérico nem acesso do cliente ao endereço `AOR_AGENT_RUNTIME_URL`.
