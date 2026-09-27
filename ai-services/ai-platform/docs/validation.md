# Relatório de validação — entrega 0.1.0

Data: 27/09/2026. Host Windows, Python 3.12.11 gerenciado pelo uv 0.8.22.
Este documento relata evidência e limites; não declara todas as fases concluídas.

| Área | Classificação | Evidência / limite |
| --- | --- | --- |
| Especificação | DOCUMENTED ONLY | Quatro anexos preservados e roadmap consolidado; autorização posterior permitiu iniciar sem restante da seção 101 |
| Python e dependências | TESTED LOCALLY | `uv sync`, ambiente isolado e lockfile; sem dependência do Python privado do aplicativo |
| API, corpus, autenticação | TESTED LOCALLY | Testes de configuração, token, corpus/IDs, erros e endpoints; servidor loopback com readiness 200 |
| MCP | TESTED LOCALLY | SDK oficial via TCP e initialize/list/call nos três servidores; busca real em Markdown |
| Integrações externas | TESTED WITH MOCK | Resposta HTTP/timeout/contratos em doubles quando indicado nos testes; não equivalem a backend real |
| Platform MCP / Kubernetes | IMPLEMENTED | Adaptador in-cluster e RBAC; ausência de credencial no host retorna erro; NOT TESTED ON KUBERNETES |
| Helm | TESTED LOCALLY | Lint/render e JSON Schema Kubernetes: 6 objetos padrão, 8 com PDB/policy; não prova admission/scheduling |
| Docker/Compose | IMPLEMENTED | Dockerfile e stack preparados; engine indisponível, build/execução em container não realizados neste host |
| Observabilidade | IMPLEMENTED + TESTED LOCALLY parcial | `/metrics` e audit events exercitados; Prometheus/Grafana/collector configurados, execução integrada pendente |
| Workflow de geração | TESTED WITH MOCK | Uma busca MCP e uma geração limitada; não houve inferência real |
| Modelo/vLLM/LiteLLM | IMPLEMENTED configuração | Perfil opt-in e revisão verificada no catálogo; NOT TESTED ON REAL GPU |
| Avaliações | TESTED LOCALLY | Fórmulas com casos hit/miss e dataset pequeno; não prova qualidade de retrieval em corpus real de negócio |
| Carga HTTP | TESTED LOCALLY | 100 requests, concorrência 5, loopback; resultados locais em `.tools/http-benchmark.json`; não é benchmark LLM |
| Terraform local | TESTED LOCALLY | fmt/init/validate; sem apply/destroy, sem cloud |
| Argo CD | IMPLEMENTED configuração | Project restrito e Application exigindo SHA revisado; não instalado nem sincronizado |
| CI | IMPLEMENTED | Workflow na raiz correta; não enviado/executado no GitHub; build de container pendente |
| Supply chain | TESTED LOCALLY parcial | pip-audit sem achados conhecidos após atualização; wheel/sdist gerados, asset web presente; imagens ainda sem scan/SBOM/assinatura |
| Referências | TESTED LOCALLY + pesquisa web | 114 URLs consultadas; 112 HTTP 200, duas O'Reilly com 403 no checker mas confirmadas pela pesquisa web |
| AWS/Azure/Karpenter/Crossplane | DOCUMENTED ONLY | Roadmap, fronteiras e gate de custos; NOT TESTED ON AWS / NOT TESTED ON AZURE |

## Comandos de verificação

Resultado da suíte atual: **19 testes passaram**, incluindo TCP real e casos
com mocks identificados. Ruff e mypy passaram. A auditoria cobre dependências
publicadas no PyPI; o pacote local Orzyon não possui registro de vulnerabilidades
nessa base e é indicado pelo auditor como não auditável por esse mecanismo.

```sh
uv run ruff check .
uv run ruff format --check .
uv run mypy src
uv run pytest -q
uv run pip-audit
uv build
helm lint helm/platform
helm template orzyon helm/platform -n orzyon > rendered.yaml
uv run python scripts/validate_manifests.py rendered.yaml
terraform fmt -check -recursive infrastructure/terraform
terraform -chdir=infrastructure/terraform/labs/local init -backend=false
terraform -chdir=infrastructure/terraform/labs/local validate
```

As versões iniciais de MCP, Starlette, pydantic-settings e pytest apresentaram
achados na auditoria; foram atualizadas e o lockfile foi regenerado. Não foram
ignorados IDs de vulnerabilidade para obter resultado verde.

O build de imagem usa Python 3.12.14 fixado por digest verificado no registry;
a execução Windows usou 3.12.11. A CI inclui Trivy com falha em HIGH/CRITICAL,
mas esse scan de container ainda não foi executado por falta do Docker local.
Uma versão/digest fixado melhora rastreabilidade, não atesta segurança.

Há avisos de compatibilidade/depreciação de bibliotecas (TestClient/httpx e
forward reference do lifespan no SDK MCP). Não impedem os testes, mas devem
ser acompanhados na evolução para o SDK MCP seguinte. Não foram suprimidos.

## Pendências concretas

1. Preparar Docker Linux/WSL2; executar build, Compose e kind conforme runbook.
2. Exercitar RBAC, probes, scheduling, rollback e políticas em cluster real.
3. Executar a stack de telemetria e verificar dashboards, alertas e exportação OTLP.
4. Validar hardware/GPU, compatibilidade do modelo, scan de imagens e inferência.
5. Publicar imagens/commit somente quando solicitado; instalar Argo CD e observar drift.
6. Evoluir RAG com embeddings/reranking/ACL; separar servidores/identidades e adicionar OAuth.
7. Construir módulos cloud após decisões de conta/região/orçamento, obter aprovação
   antes de recursos pagos; depois Crossplane e laboratórios avançados.

Não foram criados clusters, recursos pagos, commits, PRs ou publicações.
Nenhuma habilidade do usuário foi marcada como dominada. O corpus contém
apenas texto público escrito para o laboratório.
