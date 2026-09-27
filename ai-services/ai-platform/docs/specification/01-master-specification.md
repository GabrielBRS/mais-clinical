# ORZYON AI PLATFORM
## Engineering Specification / Master Implementation Prompt

Você atuará como Principal AI Platform Engineer, Cloud Platform Engineer,
LLM Systems Engineer e Software Architect na construção de uma plataforma
de IA corporativa chamada:

    Orzyon AI Platform

Este NÃO é um projeto de demonstração descartável.

Quero construir progressivamente uma plataforma de IA real, modular,
reprodutível, observável, segura, cloud-native, multi-cloud e orientada a
GitOps, que possa servir simultaneamente como:

1. plataforma tecnológica da Orzyon;
2. laboratório profissional de AI Platform Engineering;
3. ambiente para estudar profundamente Kubernetes, GPU scheduling,
   LLM serving, MCP, agentes, IaC, GitOps e observabilidade;
4. referência arquitetural para sistemas corporativos de IA;
5. base extensível para futuros produtos e serviços da Orzyon.

A implementação deve priorizar aprendizado técnico REAL.

Não esconda Kubernetes, Terraform, Crossplane, Helm ou outras tecnologias
atrás de scripts mágicos apenas para facilitar a execução.

Quero conseguir abrir os arquivos produzidos e entender como a plataforma
funciona.

Sempre que implementar algo, documente:

- o que foi criado;
- por que existe;
- qual problema resolve;
- como funciona;
- como executar;
- como diagnosticar;
- como testar;
- como remover/reverter;
- quais trade-offs foram considerados;
- quais alternativas existem;
- quais decisões são adequadas somente para desenvolvimento;
- quais mudanças seriam necessárias para produção.


======================================================================
1. PRINCÍPIOS FUNDAMENTAIS
======================================================================

A plataforma deve seguir estes princípios:

- Infrastructure as Code
- GitOps
- Everything as Code
- declarative infrastructure
- reproducibility
- immutable infrastructure quando aplicável
- cloud-native architecture
- multi-cloud awareness
- loose coupling
- open standards
- open source first quando tecnicamente razoável
- observability by default
- security by default
- least privilege
- zero-trust principles onde aplicável
- automated testing
- deterministic deployments
- explicit configuration
- configuration validation
- no manual production patches
- horizontal scalability
- failure-aware architecture
- graceful degradation
- cost awareness / FinOps
- SLO-driven engineering
- platform engineering / self-service
- developer experience
- separation of concerns
- documented architectural decisions

Evitar:

- configuração manual sem rastreabilidade;
- kubectl edit como mecanismo normal de operação;
- recursos criados manualmente pelo console da cloud;
- secrets commitados;
- dependência desnecessária de uma única cloud;
- scripts gigantes que escondem a arquitetura;
- abstrações prematuras;
- abstrações que impeçam compreender Kubernetes/cloud;
- componentes sem health check;
- deploy sem rollback;
- observabilidade adicionada somente depois;
- TODOs silenciosos;
- mocks apresentados como implementações reais.


======================================================================
2. OBJETIVO ARQUITETURAL
======================================================================

A arquitetura conceitual desejada é:

                         USERS
                           |
                           v
                    +--------------+
                    |   Chat Web   |
                    +------+-------+
                           |
                           v
                    +--------------+
                    | Agent Layer  |
                    +--+--------+--+
                       |        |
                    tools       | inference
                       |        |
                       v        v
                 +---------+  +----------+
                 |   MCP   |  | LiteLLM  |
                 | Servers |  | Gateway  |
                 +----+----+  +----+-----+
                      |            |
                      |            v
                      |         +------+
                      |         | vLLM |
                      |         +--+---+
                      |            |
                      |            v
                      |        LLM Models
                      |
                Internal/External
                     Systems


                 APPLICATION PLATFORM
                         |
                         v
                    Kubernetes
                   /          \
                 AKS          EKS
                               |
                           Karpenter
                               |
                    GPU Nodes / Spot


             INFRASTRUCTURE CONTROL PLANE

              Terraform + Crossplane


                 DELIVERY PLANE

                  Git -> CI
                        |
                        v
                   Helm charts
                        |
                        v
                     ArgoCD
                        |
                        v
                   Kubernetes


                OBSERVABILITY PLANE

        OpenTelemetry / Prometheus / Grafana
            logs / metrics / traces
        LLM-specific telemetry and costs


======================================================================
3. REPOSITORY STRUCTURE
======================================================================

Inicialmente utilizar um monorepo para facilitar aprendizado e rastreamento
das relações entre as diferentes camadas.

Criar aproximadamente:

orzyon-ai-platform/
|
|-- README.md
|-- LICENSE
|-- Makefile
|-- .editorconfig
|-- .gitignore
|-- .env.example
|
|-- docs/
|   |-- architecture/
|   |   |-- overview.md
|   |   |-- request-flow.md
|   |   |-- deployment-flow.md
|   |   |-- inference-flow.md
|   |   |-- mcp-flow.md
|   |   |-- gpu-scheduling.md
|   |   `-- multi-cloud.md
|   |
|   |-- adr/
|   |-- runbooks/
|   |-- troubleshooting/
|   |-- security/
|   `-- finops/
|
|-- infrastructure/
|   |
|   |-- terraform/
|   |   |-- modules/
|   |   |   |-- network/
|   |   |   |-- kubernetes/
|   |   |   |-- identity/
|   |   |   |-- observability/
|   |   |   `-- gpu/
|   |   |
|   |   `-- environments/
|   |       |-- dev/
|   |       |-- staging/
|   |       `-- prod/
|   |
|   `-- crossplane/
|       |-- providers/
|       |-- xrds/
|       |-- compositions/
|       |-- functions/
|       `-- claims/
|
|-- kubernetes/
|   |-- base/
|   |-- namespaces/
|   |-- rbac/
|   |-- network-policies/
|   |-- storage/
|   |-- gpu/
|   `-- karpenter/
|
|-- helm/
|   |-- litellm/
|   |-- vllm/
|   |-- mcp/
|   |-- agents/
|   `-- chat-web/
|
|-- gitops/
|   `-- argocd/
|       |-- projects/
|       |-- applications/
|       |-- applicationsets/
|       `-- environments/
|
|-- serving/
|   |-- vllm/
|   |-- models/
|   |-- configs/
|   `-- benchmarks/
|
|-- gateway/
|   `-- litellm/
|
|-- mcp/
|   |-- servers/
|   |   |-- platform/
|   |   |-- knowledge/
|   |   |-- observability/
|   |   `-- examples/
|   |
|   `-- clients/
|
|-- agents/
|   |-- runtime/
|   |-- examples/
|   |-- tools/
|   |-- prompts/
|   `-- evals/
|
|-- chat-web/
|
|-- observability/
|   |-- opentelemetry/
|   |-- prometheus/
|   |-- grafana/
|   |-- dashboards/
|   |-- alerts/
|   `-- collectors/
|
|-- security/
|   |-- policies/
|   |-- secrets/
|   |-- scanning/
|   `-- threat-model/
|
|-- tests/
|   |-- unit/
|   |-- integration/
|   |-- e2e/
|   |-- load/
|   `-- chaos/
|
|-- scripts/
|
`-- .github/
    `-- workflows/

A estrutura pode evoluir se houver justificativa arquitetural.
Não criar diretórios vazios apenas para parecer completo.


======================================================================
4. LOCAL DEVELOPMENT ENVIRONMENT
======================================================================

Antes de AWS/Azure, construir um ambiente local funcional.

Suportar preferencialmente:

- Docker
- Docker Compose quando apropriado
- kind ou k3d para Kubernetes local
- Helm
- kubectl

Objetivo:

    git clone
        ->
    bootstrap documentado
        ->
    Kubernetes local
        ->
    serviços principais
        ->
    testes
        ->
    observabilidade

Criar comandos convenientes, sem esconder os comandos fundamentais:

    make bootstrap
    make cluster-up
    make cluster-down
    make deploy
    make test
    make lint
    make status
    make logs
    make clean

O README deve mostrar também os comandos equivalentes executados por baixo,
para que o projeto continue servindo como treinamento.


======================================================================
5. KUBERNETES
======================================================================

Kubernetes é uma competência central deste projeto.

Implementar e estudar explicitamente:

- Pods
- Deployments
- StatefulSets quando apropriado
- Services
- Ingress/Gateway
- ConfigMaps
- Secrets
- namespaces
- resource requests
- resource limits
- probes
- readiness
- liveness
- startup probes
- affinity
- anti-affinity
- topology spread constraints
- node selectors
- labels
- annotations
- taints
- tolerations
- RBAC
- service accounts
- network policies
- storage
- PersistentVolumes/PVC quando necessário
- disruption budgets
- autoscaling
- scheduling
- rolling updates
- rollback

Criar runbooks para diagnosticar:

- Pending Pods
- CrashLoopBackOff
- ImagePullBackOff
- OOMKilled
- failed scheduling
- DNS
- networking
- readiness failures
- insufficient CPU
- insufficient memory
- insufficient GPU

Explicar e utilizar comandos como:

    kubectl get pods
    kubectl get nodes
    kubectl get events
    kubectl describe pod
    kubectl logs
    kubectl top
    kubectl get deployment
    kubectl rollout status
    kubectl rollout undo


======================================================================
6. GPU SCHEDULING
======================================================================

Criar uma área específica de estudo e implementação de GPU scheduling.

Objetivos:

- entender como Kubernetes representa GPUs;
- NVIDIA device plugin / GPU Operator quando apropriado;
- requests/limits de GPU;
- GPU node pools;
- labels;
- taints/tolerations;
- affinity;
- seleção de hardware;
- capacidade;
- VRAM;
- scheduling failure;
- autoscaling;
- Spot versus On-Demand.

Documentar a relação:

LLM
 |
 v
vLLM
 |
 v
Pod
 |
 v
Kubernetes Scheduler
 |
 v
GPU Node

Em AWS:

Pod Pending
    |
    v
Karpenter
    |
    v
EC2 GPU instance
    |
    v
Node joins EKS
    |
    v
Scheduler places Pod

Criar cenários laboratoriais que possam ser simulados localmente sem GPU
e cenários reais que só sejam habilitados quando infraestrutura compatível
estiver disponível.

NUNCA fingir que um teste sem GPU validou comportamento real de GPU.


======================================================================
7. KARPENTER
======================================================================

Adicionar Karpenter no ambiente AWS/EKS.

Estudar e implementar:

- NodePools
- EC2NodeClass
- instance selection
- capacity type
- Spot
- On-Demand
- labels
- taints
- requirements
- consolidation
- disruption
- node lifecycle
- GPU instance families

Criar cenário:

    workload requests GPU
            |
            v
       Pod Pending
            |
            v
        Karpenter
            |
            v
    choose EC2 capacity
            |
       +----+----+
       |         |
      Spot    On-Demand

Documentar:

- economia possível;
- riscos de Spot;
- interrupção;
- recuperação;
- disponibilidade;
- cold start;
- carregamento de modelos;
- impacto em inferência;
- estratégias híbridas.


======================================================================
8. TERRAFORM
======================================================================

Terraform deverá representar infraestrutura de cloud.

Criar módulos reutilizáveis para:

- networking
- IAM/identity
- Kubernetes
- storage
- observability
- GPU infrastructure

Separar:

    modules/
    environments/

Preparar:

    dev
    staging
    prod

Implementar:

- variables
- outputs
- locals
- providers
- modules
- remote state quando entrarmos em cloud
- state locking quando aplicável
- validation
- fmt
- validate
- plan
- apply
- destroy

CI deve executar pelo menos:

    terraform fmt -check
    terraform validate

Documentar cuidadosamente state e riscos de mudanças destrutivas.


======================================================================
9. MULTI-CLOUD: AWS + AZURE
======================================================================

Objetivo:

AWS:
    EKS

Azure:
    AKS

Não tentar artificialmente tornar tudo idêntico.

Queremos estudar:

    PARIDADE QUANDO FAZ SENTIDO
    +
    EXCEÇÕES DOCUMENTADAS

Criar documentação comparando:

- networking;
- identity;
- load balancing;
- storage;
- GPU instances;
- autoscaling;
- secrets;
- observability;
- ingress;
- costs;
- Spot/preemptible capacity;
- managed Kubernetes differences.

Toda divergência relevante deverá poder ser registrada através de ADR.


======================================================================
10. CROSSPLANE
======================================================================

Crossplane deve ser estudado depois que os fundamentos de Terraform e
Kubernetes estiverem claros.

Objetivo:

criar uma API interna de plataforma.

Por exemplo:

apiVersion: platform.orzyon.ai/v1alpha1
kind: AIInference
metadata:
  name: qwen
spec:
  model: ...
  environment: dev
  accelerator:
    type: gpu
    count: 1

Estudar e implementar:

- Providers
- Managed Resources
- XRD
- Composite Resources
- Compositions
- Composition Functions quando justificadas
- Claims, dependendo da versão/arquitetura adotada

Queremos entender:

Developer
    |
    v
AIInference
    |
    v
XRD
    |
    v
Composition
    |
    v
Cloud Resources

Comparar explicitamente:

Terraform vs Crossplane.

Não apresentar Crossplane como substituto universal de Terraform.

Documentar quando cada abordagem é mais adequada.


======================================================================
11. HELM
======================================================================

Criar Helm charts para componentes apropriados.

Estudar:

- Chart.yaml
- values.yaml
- templates
- helpers
- environment-specific values
- dependency management
- lint
- template rendering
- upgrades
- rollback

Evitar duplicação de YAML.

Entretanto, não criar templates excessivamente abstratos e impossíveis de
compreender.


======================================================================
12. ARGO CD / GITOPS
======================================================================

Git deverá ser a source of truth dos deployments.

Fluxo:

Developer
    |
    v
Git commit
    |
    v
Pull Request
    |
    v
Merge
    |
    v
ArgoCD
    |
    v
Helm
    |
    v
Kubernetes

Implementar:

- Applications
- Projects
- ApplicationSets quando justificável
- sync policies
- health
- drift detection
- reconciliation
- rollback strategy

Não utilizar patches manuais como procedimento operacional normal.

Criar laboratório de drift:

1. Git define replicas=2.
2. alguém altera cluster manualmente para replicas=5.
3. detectar drift.
4. observar reconciliação.
5. explicar o resultado.


======================================================================
13. LLM SERVING COM vLLM
======================================================================

vLLM será o principal runtime experimental de inferência.

Estudar:

- model loading
- OpenAI-compatible API
- batching
- continuous batching
- KV cache
- context length
- throughput
- latency
- TTFT
- tokens/s
- concurrency
- GPU memory utilization
- tensor parallelism
- quantization quando apropriada
- prefix caching quando aplicável
- tool calling
- reasoning parsers conforme modelos suportados

Construir benchmarks.

Registrar:

- model
- hardware
- VRAM
- concurrency
- context length
- input tokens
- output tokens
- TTFT
- throughput
- latency
- errors

Objetivo:

tomar decisões quantitativas entre:

QUALITY
LATENCY
COST


======================================================================
14. KV CACHE
======================================================================

Criar documentação específica sobre KV cache.

Explicar relação entre:

- attention
- tokens anteriores
- context length
- concurrency
- memory
- VRAM
- throughput

Criar experimentos comparando diferentes:

- context lengths;
- concurrencies;
- model sizes;
- memory utilization settings.

Não reduzir tuning de LLM a "aumentar contexto".


======================================================================
15. LITELLM GATEWAY
======================================================================

LiteLLM será utilizado como gateway de modelos.

Fluxo:

Application
    |
    v
LiteLLM
    |
    +----> vLLM local
    |
    +----> provider externo opcional
    |
    +----> Bedrock futuramente

Implementar progressivamente:

- model routing
- authentication
- authorization quando suportada/adequada
- budgets
- usage tracking
- cost attribution
- rate limiting
- retries
- fallbacks
- timeout
- provider abstraction
- observability hooks

Investigar hooks para:

- auth
- billing
- routing
- logging
- telemetry

Criar testes de falha:

Provider A unavailable
        |
        v
      retry?
        |
        v
     fallback
        |
        v
Provider B


======================================================================
16. MCP
======================================================================

Implementar Model Context Protocol de verdade.

Criar inicialmente pelo menos três servidores MCP educacionais:

1. platform-mcp
2. knowledge-mcp
3. observability-mcp

Exemplos de tools:

platform-mcp:

    get_cluster_status
    list_deployments
    get_model_status

knowledge-mcp:

    search_documents
    retrieve_document

observability-mcp:

    query