CONTINUAÇÃO FINAL DA ESPECIFICAÇÃO — ORZYON AI PLATFORM

Esta mensagem continua diretamente a seção 45 da especificação anterior,
que foi truncada após a palavra "Terraform".

Não iniciar implementação antes de incorporar esta continuação ao conjunto
de especificações.

======================================================================
45. DOCUMENTAÇÃO OFICIAL MÍNIMA
======================================================================

Criar uma biblioteca organizada de referências oficiais para, no mínimo:

FOUNDATIONS
- Linux
- containers
- OCI
- Docker
- containerd

KUBERNETES
- Kubernetes
- kubectl
- Kubernetes Scheduler
- Kubernetes networking
- Kubernetes storage
- RBAC
- admission control
- autoscaling
- HPA
- VPA, quando relevante
- Cluster Autoscaler, para comparação
- Gateway API
- CRDs / Custom Resources
- controllers/operators

PACKAGING / GITOPS
- Helm
- Argo CD
- GitHub Actions

INFRASTRUCTURE AS CODE
- Terraform
- OpenTofu, para comparação
- Crossplane
- Crossplane Providers
- Crossplane XRDs
- Crossplane Compositions
- Crossplane Functions

AWS
- AWS fundamentals
- IAM
- VPC
- EC2
- EBS
- ECR
- EKS
- EKS networking
- EKS identity
- EC2 Spot
- GPU instances
- Karpenter
- Bedrock

AZURE
- Azure fundamentals
- Microsoft Entra ID
- Managed Identities
- VNet
- Azure Container Registry
- AKS
- AKS networking
- AKS identity
- Azure GPU VM families
- Spot VMs

GPU / ACCELERATED COMPUTING
- NVIDIA CUDA
- NVIDIA Container Toolkit
- NVIDIA Kubernetes Device Plugin
- NVIDIA GPU Operator
- DCGM
- DCGM Exporter

LLM SERVING
- vLLM
- supported model architectures
- distributed inference
- tensor parallelism
- KV cache
- quantization
- prefix caching
- structured outputs
- tool calling
- reasoning support

LLM GATEWAY
- LiteLLM
- LiteLLM Proxy/Gateway
- routing
- retries
- fallbacks
- budgets
- authentication
- observability callbacks/hooks

AGENTIC SYSTEMS
- Model Context Protocol
- MCP specification
- MCP SDKs
- LangGraph
- agent/tool calling concepts
- structured outputs

OBSERVABILITY
- OpenTelemetry
- Prometheus
- Grafana
- OpenMetrics
- NVIDIA DCGM

RAG / DATA
- PostgreSQL
- pgvector
- MongoDB where useful
- vector retrieval concepts
- hybrid retrieval
- reranking

SECURITY
- Kubernetes security documentation
- OWASP
- OWASP Top 10
- OWASP API Security
- OWASP guidance for LLM/GenAI systems where current and applicable
- Sigstore/Cosign
- SLSA
- Trivy
- Syft
- Grype

POLICY
- Kyverno
- OPA
- Gatekeeper

FINOPS
- OpenCost
- cloud provider cost documentation

PERFORMANCE
- k6
- Locust
- profiling tools appropriate to each runtime

For each resource store:

- project/resource name;
- official organization;
- canonical URL;
- category;
- why it matters;
- which module of our platform uses it;
- prerequisite knowledge;
- recommended reading order.

Do NOT fabricate URLs.

If Internet access is available, verify that links exist before recording them.
Prefer canonical official documentation rather than blog summaries.

If Internet access is unavailable, create TODO markers instead of guessing URLs.


======================================================================
46. OPEN-SOURCE SOURCE-CODE STUDY
======================================================================

This project must not teach technologies only through tutorials.

Create:

docs/learning/resources/open-source-projects.md

Include important source-code repositories worth reading.

At minimum investigate the official repositories for:

- Kubernetes
- Karpenter
- Crossplane
- Argo CD
- Helm
- vLLM
- LiteLLM
- Model Context Protocol SDKs/specification
- LangGraph
- OpenTelemetry
- Prometheus
- Grafana
- OpenCost
- NVIDIA Kubernetes Device Plugin
- NVIDIA GPU Operator

For each project explain:

1. What the project does.
2. Why it matters to our platform.
3. Which directories are worth studying first.
4. What architecture patterns can be learned from it.
5. Whether we use it directly or merely study it.
6. Difficulty level:
   - introductory
   - intermediate
   - advanced

Do NOT clone enormous repositories automatically.

Provide explicit optional commands such as:

git clone ...

only after verifying the canonical repository.

Source-code reading should be deliberate rather than downloading the entire
open-source ecosystem.


======================================================================
47. BOOK CURRICULUM
======================================================================

Create:

docs/learning/resources/books.md

Build a serious book curriculum.

Research CURRENT editions before recording edition numbers.

Potential subject areas include:

LINUX / SYSTEMS
- Linux systems administration
- Linux programming
- operating systems
- networking

DISTRIBUTED SYSTEMS
- Designing Data-Intensive Applications
- distributed systems literature
- reliability engineering

KUBERNETES
- Kubernetes architecture
- Kubernetes operations
- Kubernetes patterns
- cloud-native infrastructure

SRE
- Site Reliability Engineering
- The Site Reliability Workbook

DEVOPS
- Accelerate
- continuous delivery
- infrastructure as code

SOFTWARE ARCHITECTURE
- Fundamentals of Software Architecture
- Software Architecture: The Hard Parts
- architecture patterns

MACHINE LEARNING SYSTEMS
- Designing Machine Learning Systems
- Machine Learning Design Patterns
- ML systems engineering literature

LLM / GENERATIVE AI
Prefer technically rigorous and current material.
Avoid filling the curriculum with books merely because "AI" appears in the title.

PERFORMANCE
- systems performance
- performance engineering

SECURITY
- cloud security
- Kubernetes security
- application security

For every book provide:

Title
Author(s)
Edition if verified
Topic
Why it is useful
Priority:
    CORE
    RECOMMENDED
    OPTIONAL
When to read it in our roadmap

Do NOT copy copyrighted book content.

We only want bibliographic references and our own study notes.


======================================================================
48. PAPERS AND TECHNICAL LITERATURE
======================================================================

Create:

docs/learning/resources/papers.md

Build a reading list covering concepts behind the platform.

Potential areas:

TRANSFORMERS
- Attention Is All You Need

LLM INFERENCE
- batching
- continuous batching
- KV cache
- PagedAttention
- quantization
- speculative decoding
- distributed inference

RAG
- original RAG literature
- dense retrieval
- reranking
- hybrid retrieval
- retrieval evaluation

DISTRIBUTED SYSTEMS
- consensus
- fault tolerance
- scheduling
- distributed tracing

CONTAINERS / ORCHESTRATION
- cluster scheduling
- resource allocation

AGENTS
Include academically useful literature when appropriate,
but distinguish research results from industry conventions.

For every paper:

- title;
- authors;
- year;
- canonical publication/arXiv/DOI URL;
- concept;
- why we care;
- prerequisites;
- which experiment in our platform demonstrates the concept.

Do not add papers only to make the list large.


======================================================================
49. ENGINEERING BLOGS AND REAL PRODUCTION SYSTEMS
======================================================================

Create:

docs/learning/resources/engineering-blogs.md

Research high-quality engineering material from organizations operating
large-scale systems.

Relevant areas include:

- Kubernetes operations;
- GPU infrastructure;
- inference serving;
- distributed systems;
- observability;
- SRE;
- cloud infrastructure;
- platform engineering;
- model serving;
- cost optimization.

Prefer engineering publications from organizations with demonstrated
production experience.

For each article/resource explain WHY it is useful.

Do not treat engineering blogs as authoritative specifications.
Official documentation/specifications remain the primary reference.


======================================================================
50. HANDS-ON LABORATORY CURRICULUM
======================================================================

Create:

labs/

The labs must teach by BUILDING and BREAKING systems.

Suggested progression:

LAB 001
Containers fundamentals

Build an application container manually.

Learn:
- image
- layer
- registry
- process
- namespace
- cgroup

LAB 002
Local Kubernetes

Deploy application.

Learn:
Pod
Deployment
Service
ConfigMap
Secret

LAB 003
Scheduling failure

Create unschedulable Pod.

Diagnose:
kubectl describe
events
requests
node capacity

LAB 004
Health probes

Break readiness/liveness intentionally.

LAB 005
Helm

Package application.

Upgrade and rollback.

LAB 006
GitOps

Deploy through ArgoCD.

LAB 007
Drift

Modify cluster manually.

Observe reconciliation.

LAB 008
Terraform

Provision disposable infrastructure.

Plan/apply/destroy.

LAB 009
MCP server

Implement real MCP tools.

LAB 010
MCP security

Attempt unauthorized tool invocation.

LAB 011
OpenTelemetry

Trace request across multiple services.

LAB 012
Prometheus

Expose and query metrics.

LAB 013
LLM gateway

Route request through LiteLLM.

LAB 014
vLLM

Serve an actual compatible model when hardware permits.

LAB 015
LLM benchmark

Measure TTFT/throughput/concurrency.

LAB 016
RAG

Ingest, retrieve and evaluate documents.

LAB 017
Agent + MCP

Agent discovers and invokes MCP tool.

LAB 018
Agent + RAG + MCP + LLM

Build complete request flow.

LAB 019
EKS

Provision controlled EKS environment.

LAB 020
Karpenter

Provision node dynamically.

LAB 021
GPU scheduling

Schedule real GPU workload when cloud budget permits.

LAB 022
Spot

Experiment with Spot interruption behavior.

LAB 023
AKS

Repeat relevant architecture in Azure.

LAB 024
Multi-cloud comparison

Document actual differences.

LAB 025
Crossplane

Create a Composite Resource.

LAB 026
Platform API

Request infrastructure through an internal abstraction.

LAB 027
Incident response

Inject failure and diagnose from telemetry.

LAB 028
Load test

Find bottleneck.

LAB 029
Cost analysis

Calculate infrastructure/inference cost.

LAB 030
Security

Attack our own disposable laboratory environment safely and document
defensive findings.

Every lab must contain:

README.md
objective
architecture
prerequisites
commands
expected behavior
failure scenarios
troubleshooting
cleanup
questions
production considerations

Cloud labs MUST include cleanup commands.


======================================================================
51. FAILURE LABS
======================================================================

Create a dedicated:

labs/failures/

Failure is part of the curriculum.

Scenarios should eventually include:

pod-pending/
crashloop/
oom/
bad-readiness/
dns-failure/
network-policy/
rbac-denied/
argocd-drift/
terraform-drift/
mcp-timeout/
mcp-denied/
llm-timeout/
llm-overload/
provider-failure/
gpu-unavailable/
spot-interruption/

For every scenario answer:

WHAT happened?
WHY did it happen?
HOW do we detect it?
WHICH metric shows it?
WHICH log shows it?
WHICH trace shows it?
HOW do we mitigate it?
HOW do we prevent recurrence?


======================================================================
52. TROUBLESHOOTING MINDSET
======================================================================

The platform should train engineering diagnosis rather than command memorization.

For every important incident use the model:

SYMPTOM
   |
   v
OBSERVATION
   |
   v
HYPOTHESES
   |
   v
EVIDENCE
   |
   v
ROOT CAUSE
   |
   v
MITIGATION
   |
   v
PERMANENT FIX
   |
   v
PREVENTION

Do not immediately reveal the answer in failure exercises.

Provide an optional solution section after the exercise.


======================================================================
53. ARCHITECTURE DECISION RECORDS
======================================================================

All significant choices require ADRs.

Examples:

ADR-0001-monorepo.md
ADR-0002-python-control-plane.md
ADR-0003-kubernetes.md
ADR-0004-helm.md
ADR-0005-argocd.md
ADR-0006-terraform.md
ADR-0007-crossplane-boundary.md
ADR-0008-vllm.md
ADR-0009-litellm.md
ADR-0010-mcp.md
ADR-0011-observability.md
ADR-0012-secrets.md

ADR format:

# Context

# Decision

# Alternatives considered

# Consequences

# Risks

# Revisit conditions

Do not write an ADR merely to rubber-stamp the technology already named
in this specification.

Research alternatives and state the tradeoff.


======================================================================
54. AI PLATFORM ENGINEERING KNOWLEDGE MAP
======================================================================

Create:

docs/learning/knowledge-map.md

It should visually relate:

                    AI PLATFORM ENGINEER
                           |
          +----------------+----------------+
          |                |                |
       SYSTEMS          PLATFORM           AI
          |                |                |
        Linux          Kubernetes          LLM
      Networking       Terraform          RAG
      Containers       Crossplane        Agents
      Processes        ArgoCD             MCP
      Memory           Helm               vLLM
          |                |                |
          +----------------+----------------+
                           |
                           v
                    PRODUCTION AI
                           |
                +----------+----------+
                |                     |
              SRE                  FinOps
                |                     |
         Observability            GPU Cost
         Reliability              Token Cost
         Incidents                Capacity

Use Mermaid if appropriate.


======================================================================
55. SKILL MATRIX
======================================================================

Create:

docs/learning/skill-matrix.md

Levels:

0 - Unknown
1 - Conceptual understanding
2 - Can use with documentation
3 - Can implement independently
4 - Can troubleshoot production
5 - Can design/teach/optimize

Domains:

Linux
Networking
Docker
Kubernetes
Kubernetes networking
Kubernetes scheduling
GPU scheduling
Helm
ArgoCD
Terraform
AWS
EKS
Azure
AKS
Crossplane
Karpenter
Python
Rust
C++
CUDA
vLLM
LiteLLM
MCP
RAG
Agents
LangGraph
OpenTelemetry
Prometheus
Grafana
SRE
Security
FinOps
Performance Engineering

Do NOT automatically mark skills as mastered because Codex generated code.

Mastery requires evidence from labs and user execution.


======================================================================
56. INTERVIEW / PROFESSIONAL REVIEW QUESTIONS
======================================================================

Create:

docs/learning/review-questions/

Categories corresponding to the skill matrix.

Questions must progress:

basic
intermediate
advanced
production incident
architecture

Example Kubernetes progression:

BASIC:
What is a Pod?

INTERMEDIATE:
Why use requests separately from limits?

ADVANCED:
How does the scheduler decide where a Pod can run?

INCIDENT:
A vLLM Pod requiring a GPU remains Pending. How do you investigate?

ARCHITECTURE:
How would you design GPU capacity across Spot and On-Demand nodes while
balancing availability and cost?

Do NOT generate answers immediately beside every question.

Maintain separate answer/reference material.


======================================================================
57. PRODUCTION INCIDENT SIMULATIONS
======================================================================

Create realistic exercises.

Example:

INCIDENT-001

Users report inference latency increased from normal levels.

Given:

- dashboard;
- logs;
- traces;
- Kubernetes state;
- vLLM metrics.

Student must determine whether bottleneck is:

gateway
queue
CPU
GPU
KV cache
model
network
MCP
external dependency

The goal is reasoning from evidence.


======================================================================
58. CAPACITY PLANNING
======================================================================

Add capacity-planning studies.

Questions:

How many requests can one replica handle?
When should we add another replica?
How much VRAM does a deployment require?
How does context length affect capacity?
How does concurrency affect KV cache?
What happens when queue depth increases?
When does another GPU become economically justified?

Build calculations from MEASUREMENTS.

Never invent production capacity.


======================================================================
59. GPU ECONOMICS
======================================================================

Create:

docs/finops/gpu-economics.md

Study:

GPU purchase vs cloud
On-Demand vs Spot
idle GPU cost
utilization
model density
quantization
batching
autoscaling
cold starts

Eventually calculate:

cost/request
cost/1M input tokens
cost/1M output tokens
cost/model
cost/environment

Clearly label estimates.


======================================================================
60. MODEL SERVING DECISION MATRIX
======================================================================

Create a methodology, NOT arbitrary scores.

Compare serving options according to measurable dimensions:

- supported models;
- hardware;
- throughput;
- latency;
- operational complexity;
- distributed serving;
- observability;
- ecosystem;
- cost implications.

Potential technologies to investigate include:

vLLM
Hugging Face TGI
NVIDIA Triton Inference Server
TensorRT-LLM
llama.cpp for relevant edge/local cases

Do not declare a universal winner.

Our initial implementation can use vLLM while retaining documented reasons
and alternatives.


======================================================================
61. NETWORKING DEEP DIVE
======================================================================

Add a learning track specifically for networking.

Study:

TCP/IP
DNS
TLS
HTTP/1.1
HTTP/2
HTTP/3 concepts
gRPC
load balancing
reverse proxy
NAT
CIDR
routing
firewalls
Kubernetes networking
CNI
Service
Ingress
Gateway API
NetworkPolicy

Create packet/network diagnostic labs when practical.

This is important because production Kubernetes troubleshooting requires
networking knowledge.


======================================================================
62. LINUX DEEP DIVE
======================================================================

Add practical systems labs for:

processes
signals
threads
file descriptors
permissions
namespaces
cgroups
memory
virtual memory
filesystem
network sockets
systemd
logs
resource limits

Connect these concepts to containers and Kubernetes.

Example:

Linux namespaces + cgroups
          |
          v
       containers
          |
          v
      Kubernetes


======================================================================
63. CONTAINER INTERNALS
======================================================================

Do not teach Docker as magic.

Study:

OCI image
OCI runtime
namespaces
cgroups
overlay filesystem
container networking
containerd
runc

Explain conceptually:

Docker/Kubernetes
      |
      v
container runtime
      |
      v
Linux primitives


======================================================================
64. DISTRIBUTED SYSTEMS CURRICULUM
======================================================================

Add:

docs/learning/distributed-systems.md

Topics:

partial failure
timeouts
retries
idempotency
consistency