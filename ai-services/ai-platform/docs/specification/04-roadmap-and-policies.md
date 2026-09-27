CONTINUAÇÃO DA PARTE 3 — A PARTIR DA SEÇÃO 64

Esta mensagem continua exatamente a seção 64, que foi truncada após
"consistency".

======================================================================
64. DISTRIBUTED SYSTEMS CURRICULUM — CONTINUAÇÃO
======================================================================

Topics:

partial failure
timeouts
retries
idempotency
consistency
availability
replication
partitioning
leader election
consensus concepts
backpressure
load shedding
queues
eventual consistency
distributed locks
clock/time problems
failure detection
circuit breakers
rate limiting

Relacionar esses conceitos diretamente à plataforma.

Exemplos:

LiteLLM -> retry/fallback/routing
MCP -> timeout/idempotency/security
Kubernetes -> reconciliation/eventual consistency
ArgoCD -> reconciliation/drift
Crossplane -> control loops
vLLM -> queue/backpressure/capacity
Agents -> retries/idempotency/tool failures

O objetivo não é implementar algoritmos de consenso do zero para produção.

Podemos criar pequenos laboratórios educacionais para compreender
conceitos fundamentais.


======================================================================
65. KUBERNETES INTERNALS
======================================================================

Criar uma trilha avançada para entender Kubernetes além de YAML.

Estudar:

API Server
etcd
Scheduler
Controller Manager
kubelet
container runtime
CNI
CSI
admission controllers
CRDs
operators/controllers
reconciliation loops

Documentar o fluxo:

kubectl apply
     |
     v
API Server
     |
     v
etcd
     |
     +------> Controllers
     |
     +------> Scheduler
                  |
                  v
                Node
                  |
                  v
               kubelet
                  |
                  v
          container runtime

Criar laboratórios para observar:

- scheduling;
- events;
- reconciliation;
- controller behavior;
- Pod lifecycle;
- node failure.

Isso é fundamental para troubleshooting real.


======================================================================
66. KUBERNETES SCHEDULER DEEP DIVE
======================================================================

Estudar:

scheduling queue
filtering
scoring
binding
resource requests
node affinity
pod affinity
anti-affinity
taints
tolerations
topology
priority
preemption

Relacionar diretamente com GPU scheduling.

Exemplo:

vLLM Pod
  |
  | requests GPU
  v
Scheduler
  |
  +--> Which nodes satisfy constraints?
  |
  +--> Which compatible node is preferable?
  |
  v
Binding

Quando nenhum node puder receber o workload:

Pod -> Pending

e o autoscaling/provisionamento deverá ser investigado.


======================================================================
67. GPU / CUDA SYSTEMS TRACK
======================================================================

Criar:

docs/learning/gpu/

Estudar:

GPU architecture
SM
CUDA cores
Tensor Cores
VRAM
memory bandwidth
PCIe
NVLink
host/device transfer
kernel execution
warp
thread
block
grid
occupancy

Depois relacionar:

LLM
 |
 v
PyTorch
 |
 v
CUDA
 |
 v
GPU

E:

vLLM
 |
 v
CUDA kernels
 |
 v
GPU execution

O objetivo é permitir compreender o que acontece abaixo do servidor de
inferência, não apenas executar vLLM.


======================================================================
68. LLM MEMORY ENGINEERING
======================================================================

Criar módulo dedicado à memória durante inferência.

Estudar conceitualmente:

model weights
KV cache
activations
runtime overhead
CUDA memory
fragmentation

Investigar relação aproximada:

TOTAL GPU MEMORY
       |
       +-- model weights
       +-- KV cache
       +-- runtime/workspace
       `-- overhead

Nunca usar uma fórmula simplificada como verdade universal.

Medir sempre que possível.

Criar experimentos alterando:

context length
batch/concurrency
model
quantization
GPU memory utilization

Registrar OOM e comportamento de degradação.


======================================================================
69. INFERENCE PERFORMANCE ENGINEERING
======================================================================

Estudar profundamente:

TTFT - Time To First Token
ITL - Inter-Token Latency
end-to-end latency
throughput
tokens/sec
requests/sec
concurrency
queue depth
batching
continuous batching

Criar gráficos e relatórios reproduzíveis.

Pergunta central:

O sistema está otimizado para:

latency?

throughput?

cost?

Não assumir que maximizar throughput é sempre correto.


======================================================================
70. MODEL PARALLELISM
======================================================================

Criar material sobre:

data parallelism
tensor parallelism
pipeline parallelism
expert parallelism quando aplicável

Relacionar com serving distribuído.

Exemplo:

Model too large for one GPU

        MODEL
          |
     +----+----+
     |         |
   GPU 0     GPU 1

Estudar comunicação entre GPUs e impacto de interconnect.

Não criar cluster distribuído caro apenas para completar um laboratório.


======================================================================
71. AI GATEWAY ENGINEERING
======================================================================

Tratar o gateway de LLM como componente de plataforma.

Responsabilidades potenciais:

authentication
authorization
routing
rate limiting
quota
budget
fallback
retry
timeout
telemetry
cost attribution
model abstraction

Fluxo:

Application
    |
    v
AI Gateway
    |
    +--> local vLLM
    +--> provider A
    +--> provider B
    `--> cloud model service

Implementar inicialmente com LiteLLM, mantendo interfaces que permitam
compreender e testar o comportamento.


======================================================================
72. MCP DEEP DIVE
======================================================================

Além da implementação da seção 16, criar trilha aprofundada sobre MCP.

Estudar:

client
server
transport
tools
resources
prompts
capability negotiation
sessions/lifecycle conforme a especificação atual
authorization/security conforme documentação atual

Criar fluxo:

Agent/Application
      |
      v
MCP Client
      |
      v
MCP Protocol
      |
      v
MCP Server
      |
      +--> Tool
      +--> Resource
      `--> External System

Comparar:

direct REST integration

vs

internal SDK

vs

MCP

Documentar vantagens e custos.

Não afirmar que MCP substitui APIs.


======================================================================
73. AGENT RUNTIME ENGINEERING
======================================================================

Estudar agentes como sistemas distribuídos e stateful, não somente prompts.

Componentes:

state
context
LLM calls
tools
MCP
memory
checkpoints
retries
timeouts
human approval
evaluation
telemetry

Separar:

LLM reasoning

de

deterministic application logic.

Sempre que uma regra puder ser deterministicamente garantida, avaliar
se ela realmente deve depender de uma decisão probabilística do modelo.


======================================================================
74. AGENT SAFETY
======================================================================

Criar threat model específico.

Cenários:

prompt injection
indirect prompt injection
malicious retrieved document
malicious MCP response
tool abuse
privilege escalation
data exfiltration
infinite agent loops
cost explosion

Implementar controles progressivamente:

tool allowlists
timeouts
max iterations
budgets
authorization
input validation
output validation
human approval for sensitive actions
audit trail


======================================================================
75. RAG ENGINEERING DEEP DIVE
======================================================================

Não tratar RAG como:

document -> vector DB -> LLM

apenas.

Estudar:

document parsing
normalization
chunking
metadata
embedding
indexing
filtering
dense retrieval
sparse retrieval
hybrid retrieval
reranking
context construction
citation
evaluation
freshness
document deletion
access control

Adicionar failure cases:

relevant document not retrieved
wrong chunk
stale document
unauthorized document
conflicting documents
bad metadata
embedding mismatch


======================================================================
76. DATA AND TENANCY
======================================================================

Preparar a arquitetura para compreender:

tenant
user
organization
environment

Estudar isolamento:

application-level
database-level
namespace-level
cloud-account/subscription-level

Não implementar multi-tenancy complexo antes de existir necessidade.

Entretanto, evitar decisões que impossibilitem isolamento futuro.


======================================================================
77. API ENGINEERING
======================================================================

Para APIs internas estudar:

REST
OpenAPI
gRPC quando apropriado
versioning
pagination
idempotency
authentication
authorization
rate limiting
timeouts
error models

Criar contratos claros.

Adicionar contract tests quando houver múltiplos serviços.


======================================================================
78. DATABASES
======================================================================

Adicionar trilha prática sobre persistência.

Estudar pelo menos:

PostgreSQL
pgvector
MongoDB

Não utilizar todos obrigatoriamente.

Escolher banco conforme problema.

Comparar:

relational
document
vector capabilities

Documentar decisão por ADR quando um banco entrar no caminho principal.


======================================================================
79. CACHE AND QUEUES
======================================================================

Estudar quando necessário:

Redis
message queues
event streaming concepts

Não adicionar Redis/Kafka apenas para aumentar a stack.

Introduzir somente quando houver problema concreto como:

caching
distributed coordination
asynchronous processing
event delivery

Toda introdução deverá possuir ADR.


======================================================================
80. DEVELOPER EXPERIENCE
======================================================================

A plataforma deve ser utilizável por outros engenheiros.

Objetivo futuro:

new developer
     |
     v
clone
     |
     v
bootstrap
     |
     v
local environment
     |
     v
first request

com documentação suficiente para reduzir conhecimento tribal.

Criar:

CONTRIBUTING.md

e documentação de onboarding.


======================================================================
81. INTERNAL DEVELOPER PLATFORM
======================================================================

Somente após componentes fundamentais estarem maduros, estudar conceitos de
Internal Developer Platform.

Investigar:

service catalog
golden paths
templates
self-service infrastructure
platform APIs
developer portal

Backstage pode ser estudado como referência, mas NÃO deve ser instalado
automaticamente.

O objetivo é compreender Platform Engineering, não colecionar ferramentas.


======================================================================
82. BACKUP / DISASTER RECOVERY
======================================================================

Estudar:

RPO
RTO
backup
restore
state recovery
configuration recovery

Classificar componentes:

stateless
stateful
reconstructable from Git
requires backup

Testar restore de componentes apropriados.


======================================================================
83. ENVIRONMENT STRATEGY
======================================================================

Definir claramente:

local
dev
staging
prod

Evitar copiar configurações manualmente.

Investigar estratégias adequadas para diferenças entre ambientes.

Toda diferença significativa deve ser explícita e versionada.


======================================================================
84. CONFIGURATION MANAGEMENT
======================================================================

Separar:

code
configuration
secret

Validar configuração na inicialização.

Fail fast para configurações inválidas.

Documentar precedência:

defaults
config file
environment
secret provider

quando aplicável.


======================================================================
85. VERSIONING
======================================================================

Definir estratégia para:

application versions
container tags
Helm charts
Terraform modules
platform APIs
MCP contracts

Evitar `latest` em ambientes controlados.

Preferir versões imutáveis/rastreáveis.


======================================================================
86. RELEASE ENGINEERING
======================================================================

Estudar:

rolling deployment
blue/green
canary

Não implementar todas as estratégias imediatamente.

Criar laboratório comparativo posteriormente.

Relacionar deployment de LLM com:

large image/model downloads
warmup
GPU allocation
readiness
cold start


======================================================================
87. MODEL ROLLOUT
======================================================================

Criar processo específico para modelos.

Candidate model
     |
     v
offline evaluation
     |
     v
benchmark
     |
     v
controlled deployment
     |
     v
production metrics
     |
     v
promote / rollback

Registrar:

model version
runtime version
configuration
evaluation
hardware
deployment


======================================================================
88. MODEL AND PROMPT VERSIONING
======================================================================

Versionar:

prompts
agent configuration
model selection
retrieval configuration

Uma mudança de prompt pode alterar comportamento de produção e deve ser
tratada como mudança de software quando relevante.


======================================================================
89. EXPERIMENT TRACKING
======================================================================

Para benchmarks/evals registrar:

experiment id
commit SHA
model
hardware
runtime
parameters
dataset
timestamp
results

Objetivo:

resultado reproduzível.

Não aceitar:

"pareceu mais rápido"

como benchmark.


======================================================================
90. COST GUARDRAILS
======================================================================

Antes de qualquer recurso pago de cloud:

1. documentar recurso;
2. região;
3. estimativa de custo;
4. motivo;
5. duração esperada;
6. comando/procedimento de destruição;
7. verificar se existe alternativa local;
8. obter aprovação humana antes de provisionar.

Codex NÃO está autorizado a criar automaticamente recursos pagos
simplesmente porque possui credenciais.

Especialmente:

GPU instances
EKS
AKS
NAT Gateway
load balancers
managed databases

podem gerar custos significativos.


======================================================================
91. DESTRUCTIVE ACTION POLICY
======================================================================

Operações potencialmente destrutivas devem exigir confirmação humana.

Exemplos:

terraform destroy
kubectl delete namespace
cloud resource deletion
database deletion
secret rotation
production changes

Automação não significa ausência de controle.


======================================================================
92. SOURCE CONTROL
======================================================================

O projeto está localizado dentro de um repositório Git existente.

NÃO criar repositório Git aninhado.

Respeitar:

mais-clinical/
    ai-services/
        ai-platform/

Workflows GitHub Actions devem permanecer na raiz Git apropriada:

mais-clinical/.github/workflows/

Arquivos específicos da plataforma podem utilizar nomes como:

ai-platform-ci.yml

Não modificar partes não relacionadas do monorepo sem necessidade.


======================================================================
93. LANGUAGE STRATEGY
======================================================================

Caminho principal:

Python

para:

control plane
MCP
agents
RAG
automation/backend

quando apropriado.

Rust:

laboratórios e componentes onde performance, segurança de memória ou
concorrência justifiquem investigação.

C++/CUDA:

baixo nível, kernels e estudo de GPU.

Não usar múltiplas linguagens apenas por preferência pessoal.

Cada linguagem adicional aumenta custo operacional.


======================================================================
94. DEPENDENCY MANAGEMENT
======================================================================

Para Python escolher e documentar uma estratégia reprodutível.

Pode ser avaliado:

uv

com:

pyproject.toml
lockfile
isolated environment

Não depender do Python privado de outro aplicativo do monorepo.

Definir versão suportada explicitamente.

Evitar assumir compatibilidade com Python 3.14 se bibliotecas de AI ainda
não a suportarem adequadamente.

Preferir versão amplamente suportada pelo ecossistema escolhido.


======================================================================
95. LOCAL WINDOWS + WSL STRATEGY
======================================================================

O ambiente atual observado é Windows/PowerShell.

Investigar se WSL2 está disponível.

Para Kubernetes/cloud-native development no Windows, preferir uma estratégia
reproduzível e documentada.

Não assumir que uma ferramenta ausente no PATH do PowerShell também está
ausente no WSL.

Documentar separadamente:

Windows host
WSL/Linux development environment
Docker runtime
kubectl
Helm
Terraform
cloud CLIs


======================================================================
96. COMMAND EXPLANATION
======================================================================

Como este projeto também é educacional, quando comandos importantes forem
introduzidos, explicar:

command
arguments
effect
expected output
common failure
reversal/cleanup

Exemplo:

kubectl describe pod <pod>

não apenas mandar executar.

Explicar que ele apresenta estado detalhado e eventos úteis para
troubleshooting.


======================================================================
97. DO NOT FAKE SUCCESS
======================================================================

Regra crítica.

Nunca marcar como concluído algo que não foi realmente executado.

Estados possíveis:

IMPLEMENTED
TESTED LOCALLY
TESTED WITH MOCK
TESTED ON KUBERNETES
TESTED ON REAL GPU
TESTED ON AWS
TESTED ON AZURE
DOCUMENTED ONLY
BLOCKED

Usar essas classificações nos relatórios quando apropriado.

Exemplo:

Karpenter manifests created:
IMPLEMENTED

Karpenter provisioned GPU node:
NOT TESTED ON AWS

Isso é preferível a uma falsa conclusão.


======================================================================
98. DEFINITION OF DONE
======================================================================

Uma entrega técnica só pode ser considerada concluída quando, conforme
aplicável:

- código existe;
- configuração existe;
- documentação existe;
- testes existem;
- testes relevantes passaram;
- health checks existem;
- observabilidade existe;
- security implications foram avaliadas;
- rollback/cleanup foi documentado;
- failure mode foi exercitado;
- limitações são conhecidas;
- referências estão documentadas;
- usuário possui exercício para reproduzir o conhecimento.

Para recursos que exigem cloud/GPU, registrar claramente o nível real de
validação.


======================================================================
99. IMPLEMENTATION PHILOSOPHY
======================================================================

Não gerar milhares de arquivos de uma só vez.

Implementar vertical slices.

Cada slice deverá resultar em algo compreensível e executável.

Preferir:

small
working
tested
documented

antes de:

large
complex
unverified.


======================================================================
100. EXECUTION ROADMAP
======================================================================

Agora consolidar toda a especificação recebida nas partes anteriores e
utilizar o seguinte roadmap macro.

PHASE 0 — FOUNDATION

- consolidate specifications;
- architecture overview;
- ADR structure;
- dependency strategy;
- local environment;
- learning roadmap;
- skill matrix;
- references.

PHASE 1 — LOCAL PLATFORM

- containerized service;
- Kubernetes local;
- Helm;
- health;
- basic security;
- tests;
- troubleshooting labs.

PHASE 2 — OBSERVABILITY + MCP

- OpenTelemetry;
- Prometheus;
- Grafana;
- MCP servers;
- MCP client;
- security tests.

PHASE 3 — AI INFERENCE

- LiteLLM;
- vLLM where hardware permits;
- model registry;
- metrics;
- benchmarks.

PHASE 4 — GITOPS

- ArgoCD;
- GitOps;
- drift;
- CI;
- supply chain.

PHASE 5 — RAG + AGENTS

- ingestion;
- retrieval;
- evaluation;
- Knowledge MCP;
- agent runtime;
- tool calling;
- tracing.

PHASE 6 — AWS

- Terraform;
- networking;
- identity;
- EKS;
- Karpenter;
- GPU;
- Spot.

ONLY AFTER HUMAN APPROVAL FOR PAID RESOURCES.

PHASE 7 — AZURE

- AKS;
- equivalent platform deployment;
- differences documented.

ONLY AFTER HUMAN APPROVAL FOR PAID RESOURCES.

PHASE 8 — CROSSPLANE

- Providers;
- XRD;
- Composition;
- internal platform API.

PHASE 9 — ADVANCED PLATFORM

- SRE;
- FinOps;
- security policies;
- capacity planning;
- chaos/failure labs;
- model rollout.

PHASE 10 — SYSTEMS LABS

- Rust;
- C++;
- CUDA;
- lower-level performance studies.


======================================================================
101. FIRST IMPLEMENT