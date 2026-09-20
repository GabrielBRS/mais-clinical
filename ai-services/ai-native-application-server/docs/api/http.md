# HTTP

Servidas pelo processo Mojo (`pixi run run`). Host/porta: `AOR_HTTP_HOST` /
`AOR_HTTP_PORT` (default `0.0.0.0:8080`).

| Método | Path | Endpoint | Handler | Use case |
| --- | --- | --- | --- | --- |
| `GET` | `/health` | `health.live` | `handle_health_live` | `GetHealthUseCase` |
| `GET` | `/health/live` | `health.live` | `handle_health_live` | `GetHealthUseCase` |
| `GET` | `/health/ready` | `health.ready` | `handle_health_ready` | `GetHealthUseCase` (503 se não ready) |
| `POST` | `/agents/execute` | `agent.execute` | `handle_agent_execute` | `ExecuteAgentUseCase` |
| `POST` | `/workflows/execute` | `workflow.execute` | `handle_workflow_execute` | `ExecuteWorkflowUseCase` |

```bash
curl -s http://127.0.0.1:8080/health
curl -s -X POST http://127.0.0.1:8080/agents/execute \
  -H 'Content-Type: application/json' \
  -d '{"agent_id":"default","prompt":"hello mojo","retrieve":false}'
curl -s -X POST http://127.0.0.1:8080/agents/execute \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"hello mojo","backend":"graph"}'
curl -s -X POST http://127.0.0.1:8080/workflows/execute \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"ACE1"}'
```
