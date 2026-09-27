CONTINUAÇÃO DA ESPECIFICAÇÃO — ORZYON AI PLATFORM

IMPORTANTE:

A mensagem anterior foi truncada durante a seção 16 (MCP).
NÃO considere a especificação encerrada.

Continue utilizando tudo que foi definido anteriormente e acrescente
integralmente os requisitos abaixo.

Além de implementar a plataforma, este repositório deverá funcionar como
um laboratório profissional de estudo de AI Platform Engineering.

O objetivo não é simplesmente "fazer funcionar".

Para cada tecnologia importante, quero:

1. implementação real;
2. explicação arquitetural;
3. documentação oficial de referência;
4. projetos open source relevantes para estudar;
5. livros, papers ou materiais técnicos relevantes;
6. exercícios;
7. laboratórios reproduzíveis;
8. troubleshooting;
9. perguntas que um engenheiro deveria conseguir responder;
10. trade-offs de produção;
11. anti-patterns;
12. critérios para saber quando considero aquele assunto dominado.

Não copiar livros ou documentação protegida para dentro do repositório.
Criar apenas referências, links, notas próprias e exercícios.


======================================================================
16. MCP — MODEL CONTEXT PROTOCOL
======================================================================

Implementar Model Context Protocol de forma real.

Não quero apenas um exemplo "hello world".

Criar inicialmente pelo menos três servidores MCP:

mcp/
├── servers/
│   ├── platform-mcp/
│   ├── knowledge-mcp/
│   └── observability-mcp/
└── clients/


--------------------------------------------------
16.1 PLATFORM MCP
--------------------------------------------------

Responsável por disponibilizar informações controladas sobre a plataforma.

Começar com tools READ-ONLY.

Exemplos:

get_cluster_status()
list_namespaces()
list_deployments()
get_deployment_status()
get_model_status()
list_models()
get_inference_health()

IMPORTANTE:

Não permitir inicialmente que um agente execute operações destrutivas
arbitrárias no Kubernetes.

Separar claramente:

READ operations
WRITE operations
DESTRUCTIVE operations

Qualquer futura operação destrutiva deverá exigir políticas explícitas,
autorização e auditabilidade.


--------------------------------------------------
16.2 KNOWLEDGE MCP
--------------------------------------------------

Criar servidor responsável por recuperação de conhecimento.

Exemplos:

search_documents()
retrieve_document()
list_collections()
get_document_metadata()

Esse servidor será posteriormente integrado a uma implementação RAG.


--------------------------------------------------
16.3 OBSERVABILITY MCP
--------------------------------------------------

Permitir que agentes consultem observabilidade da plataforma.

Exemplos:

query_metrics()
get_service_health()
get_recent_errors()
get_inference_metrics()
get_gpu_metrics()

Posteriormente poderemos experimentar um agente de diagnóstico:

Incident
   |
   v
Agent
   |
   v
Observability MCP
   |
   +--> Prometheus
   +--> logs
   +--> traces
   |
   v
diagnostic hypothesis

O agente NÃO deverá executar automaticamente ações destrutivas.


--------------------------------------------------
16.4 MCP SECURITY
--------------------------------------------------

Estudar e documentar:

- authentication;
- authorization;
- tool permissions;
- least privilege;
- user-scoped connectors;
- audit logs;
- secret handling;
- prompt injection;
- tool poisoning;
- confused deputy problems;
- SSRF;
- unsafe tool invocation;
- data exfiltration;
- tenant isolation.

Criar threat model específico para MCP.


======================================================================
17. AGENT PLATFORM
======================================================================

Criar uma camada de agentes separada do serving.

Arquitetura:

User
 |
 v
Agent Runtime
 |
 +--------> LLM Gateway
 |
 +--------> MCP
 |
 +--------> RAG
 |
 +--------> internal tools

Quero estudar:

- single-agent;
- multi-agent;
- deterministic workflows;
- graph-based orchestration;
- tool calling;
- structured outputs;
- state;
- retries;
- timeouts;
- checkpointing;
- human-in-the-loop;
- agent memory;
- context management;
- guardrails;
- evaluation.

Podemos utilizar Python inicialmente.

LangGraph pode ser utilizado para experimentos e comparação.

Entretanto:

NÃO acoplar toda a arquitetura da plataforma a LangGraph.

Definir interfaces claras para permitir substituir o framework.


======================================================================
18. MULTI-AGENT LAB
======================================================================

Criar posteriormente um laboratório multiagente.

Implementar pelo menos um padrão:

Agent A
     \
      \
       -> Mediator/Leader -> deterministic verdict
      /
Agent B

Objetivo:

estudar quando multi-agent realmente oferece vantagem e quando apenas
aumenta:

- custo;
- latência;
- complexidade;
- superfície de falha.

Comparar experimentalmente:

single agent

vs

multi-agent

usando métricas.


======================================================================
19. RAG PLATFORM
======================================================================

Criar uma implementação RAG independente.

Pipeline:

Documents
   |
   v
Parsing
   |
   v
Chunking
   |
   v
Embedding
   |
   v
Vector Store
   |
   v
Retrieval
   |
   v
Reranking
   |
   v
Context
   |
   v
LLM

Estudar:

- chunking;
- metadata;
- embeddings;
- hybrid search;
- vector search;
- lexical search;
- reranking;
- filtering;
- citations;
- retrieval evaluation;
- ingestion;
- document versioning;
- deletion;
- multi-tenancy.

Criar métricas:

Recall@K
Precision@K
MRR
nDCG

e avaliações de resposta quando apropriado.

O RAG deverá poder ser acessado através do Knowledge MCP.


======================================================================
20. OBSERVABILITY
======================================================================

Observabilidade será requisito de primeira classe.

Implementar progressivamente:

OpenTelemetry
Prometheus
Grafana

e solução de logs adequada ao laboratório.

Queremos observar:

APPLICATION

- request rate;
- latency;
- errors;
- saturation.

KUBERNETES

- CPU;
- RAM;
- Pods;
- nodes;
- restarts;
- scheduling failures.

GPU

- utilization;
- VRAM;
- temperature quando disponível;
- power quando disponível;
- workload allocation.

LLM

- TTFT;
- tokens/sec;
- prompt tokens;
- completion tokens;
- context length;
- inference latency;
- queue time;
- model;
- errors.

AGENTS

- execution duration;
- model calls;
- tool calls;
- retries;
- failures;
- token usage;
- estimated cost.

MCP

- tool latency;
- tool failures;
- caller;
- tool name;
- authorization result.

Criar dashboards reais.


======================================================================
21. DISTRIBUTED TRACING
======================================================================

Quero conseguir seguir uma requisição aproximadamente assim:

User Request
      |
      v
Chat
      |
      v
Agent
      |
      +---- MCP tool
      |
      v
LiteLLM
      |
      v
vLLM
      |
      v
Model

Tudo deverá compartilhar correlação de tracing quando tecnicamente possível.

Estudar:

trace_id
span_id
parent/child spans
context propagation

Usar OpenTelemetry como base aberta.


======================================================================
22. LLM OBSERVABILITY
======================================================================

Além de OpenTelemetry, criar uma camada específica para aplicações LLM.

Avaliar ferramentas open source adequadas.

Não introduzir dependência obrigatória sem ADR.

Queremos visualizar:

Agent
 |
 +-- LLM call
 |
 +-- tool call
 |
 +-- retrieval
 |
 +-- reranking
 |
 `-- final answer

Registrar cuidadosamente dados sensíveis.

NÃO assumir que prompts e respostas podem sempre ser armazenados.


======================================================================
23. EVALUATION / EVALS
======================================================================

Criar framework de avaliação.

Separar:

deterministic evaluation
model-based evaluation
human evaluation

Testar:

- tool selection;
- structured output;
- retrieval;
- hallucination;
- groundedness;
- task completion;
- latency;
- cost.

LLM-as-a-judge poderá ser usado, mas nunca tratado como verdade absoluta.

Registrar:

model
prompt/version
dataset
result
timestamp
configuration


======================================================================
24. MODEL REGISTRY
======================================================================

Criar catálogo lógico de modelos.

Exemplo:

models.yaml

models:
  - id: qwen-example
    provider: local
    runtime: vllm
    capabilities:
      tool_calling: true
      reasoning: true
    context_window: ...
    deployment_class: ...

Não preencher números inventados.

Dados específicos deverão vir de documentação ou benchmark real.


======================================================================
25. MODEL ROUTING
======================================================================

Criar laboratório de roteamento.

Exemplo:

simple request
      |
      v
small/cheap model

complex request
      |
      v
larger model

tool-heavy request
      |
      v
model optimized for tool use

Avaliar:

quality
latency
cost
reliability

LiteLLM poderá participar dessa camada.


======================================================================
26. BACKEND / CONTROL PLANE
======================================================================

Criar backend em Python para APIs administrativas necessárias.

Preferir:

Python 3.12+
FastAPI quando adequado
Pydantic
asyncio quando necessário

Manter:

API
   |
Application
   |
Domain
   |
Infrastructure

quando essa separação trouxer benefício real.

Não aplicar Clean Architecture dogmaticamente.


======================================================================
27. RUST LAB
======================================================================

Adicionar uma área experimental opcional:

labs/rust/

Objetivo:

estudar componentes de plataforma de alta performance em Rust.

Possíveis experimentos:

- MCP server;
- gateway;
- telemetry collector;
- streaming service;
- inference proxy.

NÃO reescrever componentes Python em Rust sem benchmark ou justificativa.

Toda reescrita deverá responder:

"qual problema estamos resolvendo?"


======================================================================
28. C++ / CUDA LAB
======================================================================

Adicionar:

labs/cpp/
labs/cuda/

Objetivo educacional:

compreender a camada abaixo de vLLM/PyTorch.

Estudar progressivamente:

C++
memory management
RAII
threads
SIMD
CUDA programming model
kernel
block
thread
warp
shared memory
global memory
memory transfer
profiling

Posteriormente criar pequenos kernels educacionais.

Isso NÃO precisa fazer parte do caminho crítico da plataforma.


======================================================================
29. SECURITY
======================================================================

Criar threat model da plataforma.

Cobrir:

- identity;
- authentication;
- authorization;
- RBAC;
- workload identity;
- secrets;
- network policies;
- container security;
- image scanning;
- dependency scanning;
- supply chain;
- MCP security;
- LLM prompt injection;
- tool abuse;
- RAG poisoning;
- sensitive data;
- auditability.

Nunca armazenar credenciais reais no Git.

Fornecer:

.env.example

e documentação para secret management.


======================================================================
30. SOFTWARE SUPPLY CHAIN
======================================================================

Adicionar progressivamente:

- dependency scanning;
- container scanning;
- SBOM;
- image provenance;
- pinned versions;
- reproducible builds quando possível.

Avaliar ferramentas como:

Trivy
Syft
Grype
Cosign

Não instalar todas automaticamente sem necessidade.

Documentar a escolha.


======================================================================
31. POLICY AS CODE
======================================================================

Adicionar laboratório de Policy as Code.

Avaliar:

Kyverno
ou
OPA/Gatekeeper.

Criar políticas educacionais como:

- containers não podem rodar privileged;
- images precisam vir de registries permitidos;
- resources precisam possuir requests/limits;
- namespaces de produção possuem regras mais rígidas.

Começar em audit mode antes de enforcement quando apropriado.


======================================================================
32. SECRETS MANAGEMENT
======================================================================

Não colocar secrets reais em Helm values ou manifests.

Estudar e documentar alternativas:

- External Secrets Operator;
- cloud secret managers;
- Vault;
- SOPS.

Escolher uma estratégia inicial através de ADR.


======================================================================
33. CI/CD
======================================================================

Criar pipeline de CI.

Inicialmente GitHub Actions, salvo decisão posterior.

Pipeline deve poder executar:

Python:
    lint
    type-check
    tests

Terraform:
    fmt
    validate

Helm:
    lint
    template

Kubernetes:
    manifest validation

Security:
    dependency/container scanning

Docker:
    build

Posteriormente:

integration tests
e2e tests

CD deverá ser orientado a GitOps através de ArgoCD.


======================================================================
34. TESTING STRATEGY
======================================================================

Criar:

unit tests
integration tests
contract tests
end-to-end tests
load tests
failure tests

Adicionar posteriormente chaos engineering.

Ferramentas devem ser escolhidas conforme necessidade.

Exemplos de falhas que devemos aprender a provocar:

- matar Pod;
- indisponibilizar MCP;
- tornar provider LLM indisponível;
- simular timeout;
- quebrar readiness;
- remover capacidade;
- provocar drift;
- simular Spot interruption quando possível.


======================================================================
35. SRE
======================================================================

Definir:

SLI
SLO
error budget

para pelo menos alguns serviços.

Exemplo conceitual:

Inference Gateway

availability
latency
error rate

Não inventar metas empresariais.

Para laboratório, metas podem ser explicitamente classificadas como
EXPERIMENTAL SLO.


======================================================================
36. DORA METRICS
======================================================================

Instrumentar progressivamente:

Deployment Frequency
Lead Time for Changes
Change Failure Rate
Mean Time to Restore

Documentar:

o que cada métrica significa;
como coletar;
limitações;
como evitar gaming das métricas.


======================================================================
37. FINOPS
======================================================================

Criar camada de estudo de custos.

Queremos atribuir custos aproximadamente por:

- environment;
- namespace;
- application;
- model;
- team/squad;
- GPU workload.

Investigar:

OpenCost

e integrações adequadas.

Para inferência:

request
 |
 v
tokens
 |
 v
model
 |
 v
GPU/runtime
 |
 v
estimated cost

Diferenciar:

cloud billing real

de

estimativas internas.


======================================================================
38. PERFORMANCE ENGINEERING
======================================================================

Criar benchmarks reproduzíveis.

Para APIs:

RPS
p50
p95
p99
error rate

Para LLM:

TTFT
ITL quando disponível
tokens/sec
requests/sec
throughput
concurrency
VRAM
GPU utilization

Ferramentas possíveis:

k6
Locust
ou ferramentas especializadas.

Escolher conscientemente.


======================================================================
39. RESILIENCE
======================================================================

Testar:

- retry;
- exponential backoff;
- jitter;
- timeout;
- circuit breaker quando apropriado;
- fallback;
- graceful shutdown;
- health checks;
- load shedding quando aplicável.

Evitar retry storms.


======================================================================
40. PLATFORM ENGINEERING / SELF-SERVICE
======================================================================

A longo prazo, a plataforma deverá permitir que um desenvolvedor peça:

AIInference

em vez de precisar conhecer todos os detalhes de:

AWS
Azure
EKS
AKS
GPU
vLLM
networking
storage

Exemplo conceitual:

Developer
   |
   v
Platform API
   |
   v
AIInference
   |
   +---- Crossplane
   |
   +---- ArgoCD
   |
   +---- Kubernetes
   |
   `---- vLLM

Entretanto:

não construir um Internal Developer Platform gigante prematuramente.

Primeiro compreender os componentes.


======================================================================
41. DOCUMENTATION AS CODE
======================================================================

Toda parte importante deverá possuir documentação.

Criar:

docs/architecture/
docs/runbooks/
docs/troubleshooting/
docs/security/
docs/finops/
docs/learning/

Diagramas deverão preferencialmente ser Mermaid ou texto versionável.

Criar ADRs.

Formato:

ADR-0001-use-kubernetes.md
ADR-0002-use-vllm.md
ADR-0003-use-litellm.md
ADR-0004-gitops-with-argocd.md
...


======================================================================
42. LEARNING CENTER
======================================================================

Criar:

docs/learning/

Este diretório deverá funcionar como currículo prático.

Estrutura sugerida:

docs/learning/
|
|-- 00-roadmap.md
|-- 01-linux-containers.md
|-- 02-kubernetes.md
|-- 03-helm.md
|-- 04-gitops-argocd.md
|-- 05-terraform.md
|-- 06-aws-eks.md
|-- 07-azure-aks.md
|-- 08-crossplane.md
|-- 09-karpenter.md
|-- 10-gpu-kubernetes.md
|-- 11-vllm.md
|-- 12-litellm.md
|-- 13-mcp.md
|-- 14-rag.md
|-- 15-agents.md
|-- 16-observability.md
|-- 17-sre.md
|-- 18-security.md
|-- 19-finops.md
`-- 20-performance.md


======================================================================
43. CADA MÓDULO DE APRENDIZADO
======================================================================

Cada documento deverá conter:

# Objetivo

O que preciso dominar.

# Fundamentos

Conceitos essenciais.

# Como funciona internamente

Não ficar apenas na utilização superficial.

# Relação com nossa arquitetura

Onde essa tecnologia aparece na Orzyon AI Platform.

# Laboratório

Exercício executável.

# Failure Lab

Quebrar propositalmente alguma coisa.

# Troubleshooting

Como descobrir a causa.

# Production considerations

O que mudaria em produção.

# Perguntas de domínio

Exemplo:

- Por que este componente existe?
- Que problema resolve?
- O que acontece se cair?
- Como observar?
- Como escalar?
- Como proteger?
- Quanto custa?
- Qual alternativa existe?

# Checklist

Critérios concretos de domínio.

# Referências

Documentação oficial.
Livros.
Papers.
Projetos open source.
Talks técnicas quando relevantes.


======================================================================
44. BIBLIOTECA DE REFERÊNCIAS
======================================================================

Criar:

docs/learning/resources/

Arquivos:

official-docs.md
books.md
papers.md
open-source-projects.md
engineering-blogs.md

Não colocar referências aleatórias.

Prioridade:

1. documentação oficial;
2. especificações;
3. código-fonte dos projetos;
4. livros técnicos reconhecidos;
5. papers;
6. engineering blogs de organizações tecnicamente relevantes;
7. talks técnicas.

Para links que possam mudar, registrar:

nome
organização/autor
URL
assunto
por que estudar


======================================================================
45. DOCUMENTAÇÃO OFICIAL MÍNIMA
======================================================================

Adicionar links oficiais e organizar materiais para estudar pelo menos:

Kubernetes
AWS EKS
Azure AKS
Terraform