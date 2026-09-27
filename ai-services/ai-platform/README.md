# Orzyon AI Platform

Laboratório e base de plataforma de IA dentro de `mais-clinical/ai-services/ai-platform`.
Esta primeira entrega conecta API, três servidores MCP, recuperação lexical e
um workflow de geração através de um gateway real. O roadmap completo permanece
versionado; componentes futuros não são apresentados como instalados.

## Começar pelo ambiente Python

Requer Python 3.12 gerenciado pelo **uv 0.8.22**, sem usar o Python privado de
outro aplicativo. Instale uv conforme a [documentação oficial](https://docs.astral.sh/uv/getting-started/installation/).
No Windows, os comandos abaixo funcionam em PowerShell; Make é opcional.

```powershell
uv python install 3.12
uv sync --frozen
uv run python scripts/init_env.py
```

O script curto copia a configuração de exemplo e usa `secrets.token_urlsafe(32)`
para gerar credenciais distintas no `.env`, ignorado pelo Git, sem imprimi-las.
Ele recusa sobrescrever arquivo existente. Para configuração manual, copie o
exemplo somente se `.env` não existir e preencha os tokens. Não use os tokens
dos testes. Inicialização sem token válido falha deliberadamente.

```powershell
uv run uvicorn orzyon.api:create_app --factory --host 127.0.0.1 --port 8000 --no-access-log
```

Abra [a interface local](http://127.0.0.1:8000). A busca funciona sem GPU,
Kubernetes ou provedor externo. **Gerar resposta** exige gateway configurado;
sem ele a API responde 503. Encerrar com Ctrl+C termina somente o servidor.

Durante a criação deste projeto, uv foi instalado em `.tools/python/bin/uv.exe`.
Esse bootstrap local é ignorado pelo Git; pode ser usado no lugar de `uv` nesta
máquina. Não é uma dependência do projeto nem precisa ser copiado a outros hosts.

## O que existe

| Componente | Implementação | Limite atual |
| --- | --- | --- |
| API/interface | FastAPI, autenticação, configuração validada e interface simples | Token compartilhado de laboratório; sem OIDC ou multi-tenancy |
| Platform MCP | `list_deployments`, `get_cluster_status` via API Kubernetes | Somente namespace configurado; funciona no cluster com ServiceAccount |
| Knowledge MCP | Busca, recuperação por ID e coleções | Corpus Markdown público, lexical, limitado; sem embeddings/reranking |
| Observability MCP | Consultas Prometheus nomeadas | Sem consulta arbitrária, logs, traces ou GPU |
| Workflow | Cliente MCP real → recuperação → LiteLLM/OpenAI-compatible | Uma busca + uma geração; sem decisões probabilísticas de tools |
| Observabilidade | Métricas, audit events, spans e collector OTLP; dashboard provisionado | Collector exporta traces em log, sem armazenamento durável |
| Deploy | Dockerfile, Compose, kind, Helm, RBAC e probes | Docker/cluster ainda precisam estar disponíveis |
| IaC/GitOps | Laboratório Terraform sem cloud e manifests Argo CD | Argo CD não instalado; revision precisa de commit publicado |
| Avaliações | Precision@K, Recall@K, MRR e nDCG; teste HTTP local | Dataset pequeno de contrato; não demonstra qualidade de produção |

Os três servidores MCP têm endpoints distintos, mas compartilham um processo
nesta entrega: `/mcp/platform/`, `/mcp/knowledge/`, `/mcp/observability/`.
Todos exigem `Authorization: Bearer …`. Veja os limites no [ADR](docs/adr/ADR-0003-mcp-and-retrieval.md).

## Testar e diagnosticar

```powershell
uv run pytest -q
uv run ruff check .
uv run ruff format --check .
uv run mypy src
uv run pip-audit
uv run python scripts/evaluate_retrieval.py tests/fixtures/retrieval.json
# Em outro terminal, com servidor ativo e token no ambiente:
$env:ORZYON_API_TOKEN = '<mesmo token do .env>'
uv run python scripts/mcp_smoke.py
uv run python scripts/benchmark_http.py --count 100 --concurrency 5
```

Os testes incluem protocolo MCP e TCP com SDK oficial, isolamento de documentos,
falhas de dependências e métricas. Doubles de HTTP existem somente nos testes
unitários e não substituem validação Kubernetes, gateway ou GPU.

## Containers e Kubernetes

Siga o [runbook local](docs/runbooks/local.md) para WSL/Docker, secrets, Compose,
kind e Helm. A configuração local publica portas somente em loopback.

| Atalho | Comando fundamental / efeito |
| --- | --- |
| `make bootstrap` | `uv sync --frozen`; ambiente isolado com lockfile |
| `make serve` | `uv run uvicorn …`; servidor local |
| `make cluster-up` | `kind create cluster --name orzyon --config kubernetes/kind.yaml`; imagem de node fixada por digest |
| `make deploy` | `docker build`, `kind load docker-image`, `kubectl apply` do namespace e `helm upgrade --install --wait --atomic`; Secret deve existir |
| `make test` | `uv run pytest -q` |
| `make lint` | Ruff, mypy, `helm lint` e `helm template` |
| `make status` | `kubectl --context kind-orzyon -n orzyon get pods,deploy,svc` |
| `make logs` | `kubectl … logs deployment/orzyon-platform --tail=100` |
| `make clean` | Uninstall da release; exige confirmação explícita via `CONFIRM` |
| `make cluster-down` | Exclusão do cluster `orzyon`; exige confirmação explícita via `CONFIRM` |

As receitas de confirmação usam shell POSIX: execute Make no WSL/Linux.
No PowerShell, use diretamente os comandos equivalentes do runbook.

## Ler e evoluir

- [Arquitetura e fronteiras](docs/architecture/overview.md)
- [Roadmap e critérios de saída](docs/learning/00-roadmap.md)
- [Matriz de habilidades](docs/learning/skill-matrix.md) e [mapa](docs/learning/knowledge-map.md)
- [Referências](docs/learning/resources/official-docs.md)
- [Threat model](docs/security/threat-model.md)
- [Laboratórios](labs/README.md) e [diagnóstico](docs/troubleshooting/kubernetes.md)
- [Validação executada e pendências](docs/validation.md)
- [Especificação original](docs/specification/README.md)

Recursos AWS/Azure pagos e operações destrutivas exigem aprovação humana,
conforme seções 90–91. Este repositório não contém credenciais reais. O projeto
não foi publicado nem recebeu licença open source automaticamente; veja LICENSE.
