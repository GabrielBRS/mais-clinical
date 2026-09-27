# Laboratórios executáveis e próximos módulos

Estado de execução em `docs/validation.md`. Os comandos abaixo pressupõem a pasta
`ai-platform`, ambiente isolado e somente recursos locais autorizados.

| Lab | Exercício executável | Pré-requisitos / evidência |
| --- | --- | --- |
| 001 Containers | Dockerfile e runbook local | Docker; processo não-root e health real |
| 002 Kubernetes | kind + chart em `docs/runbooks/local.md` | Docker/kind/Helm; Pod Ready e Service acessível |
| 003 Scheduling | [pod-pending](failures/pod-pending/README.md) | Cluster; hipóteses e evento |
| 004 Probes | [bad-readiness](failures/bad-readiness/README.md) | Cluster; distinguir Running/Ready |
| 005 Helm | [upgrade](helm-upgrade/README.md) | Release local; history e rollback |
| 008 Terraform | `infrastructure/terraform/labs/local` e README | Terraform; state/plan sem cloud |
| 009–010 MCP | [MCP e segurança](mcp/README.md) | Python; SDK real e acesso negado |
| 012 Métricas | Compose + dashboard | Docker; séries reais e erro de tool |
| 016 Retrieval | `scripts/evaluate_retrieval.py` | Corpus/dataset; métricas, sem alegar RAG vetorial |
| 028 Carga | `scripts/benchmark_http.py` | Servidor local; RPS/latência/erros |

## Lab 001 — container manual

Objetivo: explicar imagem, camada, registry, processo, namespace e cgroup.
Arquitetura: host → Docker → processo uvicorn não-root. Pré-requisito: Docker
Linux funcional e token no ambiente, sem imprimir o valor nos logs.

```sh
docker build -t orzyon/platform:0.1.0 .
docker image inspect orzyon/platform:0.1.0
docker history orzyon/platform:0.1.0
docker run --name orzyon-lab001 --read-only --tmpfs /tmp --cap-drop ALL --security-opt no-new-privileges -e ORZYON_API_TOKEN -p 127.0.0.1:8000:8000 orzyon/platform:0.1.0
```

Esperado: processo iniciado, `/health/ready` responde 200. Falha: sem token o
processo deve encerrar por configuração inválida. Diagnóstico: `docker logs
orzyon-lab001`, código de saída e config; não mostrar secrets. Cleanup após
confirmação: `docker stop orzyon-lab001` e `docker rm orzyon-lab001`.
Perguntas: quem é PID 1? Quem limita RAM? Imagem é VM? Produção: digest, scan,
assinatura, limites e runtime monitorado.

## Lab 002 — Kubernetes local

Objetivo: seguir Deployment → ReplicaSet → Pod e Service → EndpointSlice.
Arquitetura/pré-requisitos/comandos: [runbook local](../docs/runbooks/local.md).
Esperado: rollout pronto e busca acessível via port-forward. Falha: omitir Secret
gera erro de configuração do container. Diagnóstico: eventos do Pod, sem imprimir
conteúdo do Secret. Cleanup confirmado: uninstall da release; cluster apenas se
não estiver em uso. Perguntas: por que ConfigMap e Secret diferem? O que persiste
se o processo morre? Produção: identidade, TLS, HA e políticas de rede.

## Labs futuros — não implementados

006–007 Argo/drift; 011 tracing multissserviço com backend; 013–015 gateway,
GPU e benchmark LLM; 017–018 agentes/RAG completos; 019–024 EKS/Karpenter/GPU/
Spot/AKS/comparação; 025–026 Crossplane/API interna; 027 incidente integrado;
029 custos reais; 030 segurança ampliada. Recursos pagos seguem gate de custo.

Cada lab novo terá README com objetivo, arquitetura, pré-requisitos, comandos,
resultado esperado, falhas, diagnóstico, cleanup, perguntas e produção. Não criar
pastas vazias. Soluções ficam depois do exercício ou em arquivo separado.
