# Biblioteca oficial — ordem de estudo

As linhas têm nome/organização, categoria, motivo, módulo e pré-requisito.
Leia pela ordem numérica; dentro de cada grupo, fundamentos antes de APIs.
Disponibilidade de links é registrada em `link-check.json`; HTTP 200 não prova
compatibilidade com a versão instalada. Consulte release notes ao atualizar.

| Ordem / recurso oficial | Categoria e por que estudar | Módulo / pré-requisito |
| --- | --- | --- |
| 1. [Linux Kernel](https://docs.kernel.org/) — Linux maintainers | Processos, memória e cgroups por baixo de containers | Sistemas / shell |
| 1. [Linux man-pages](https://www.kernel.org/doc/man-pages/) — Linux man-pages project | Syscalls, sinais, sockets e permissões | Sistemas / C básico |
| 2. [OCI specifications](https://opencontainers.org/) — Open Container Initiative | Contratos de imagem/runtime | Containers / Linux |
| 2. [Docker](https://docs.docker.com/) — Docker | Build, layers, rede e lifecycle | Lab 001 / Linux |
| 2. [containerd](https://containerd.io/docs/) — containerd | Runtime e fronteira CRI | Containers / OCI |
| 2. [WSL](https://learn.microsoft.com/en-us/windows/wsl/) — Microsoft | Separar host Windows e runtime Linux | Ambiente local / Windows |
| 2. [uv](https://docs.astral.sh/uv/) — Astral | Python, ambientes e lockfile | Foundation / Python |
| 3. [Kubernetes concepts](https://kubernetes.io/docs/concepts/) — Kubernetes | Objetos, control plane e reconciliação | Fase 1 / containers |
| 3. [kubectl](https://kubernetes.io/docs/reference/kubectl/) — Kubernetes | Efeito dos comandos e API | Fase 1 / objetos |
| 3. [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) — Kubernetes | Filtrar e pontuar nodes | Scheduling / requests |
| 3. [Networking](https://kubernetes.io/docs/concepts/services-networking/) — Kubernetes | Service, DNS, CNI e NetworkPolicy | Rede / TCP-IP |
| 3. [Storage](https://kubernetes.io/docs/concepts/storage/) — Kubernetes | PV/PVC, CSI e persistência | Estado / filesystem |
| 3. [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) — Kubernetes | Permissões mínimas verificáveis | Segurança / API |
| 3. [Admission](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/) — Kubernetes | Validação antes da persistência | Segurança / RBAC |
| 3. [HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) — Kubernetes | Escalar Pods por métricas | Capacidade / métricas |
| 3. [Autoscaler](https://github.com/kubernetes/autoscaler) — Kubernetes | VPA e Cluster Autoscaler para comparação | Capacidade / scheduler |
| 3. [Gateway API](https://gateway-api.sigs.k8s.io/) — Kubernetes SIG Network | Roteamento e divisão de responsabilidades | Rede / Services |
| 3. [CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) — Kubernetes | Estender API e construir controllers | Fase 8 / reconciliação |
| 3. [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) — Kubernetes SIGs | Kubernetes em containers locais | Fase 1 / Docker |
| 4. [Helm](https://helm.sh/docs/) — Helm | Charts, values, templates e releases | Fase 1 / YAML |
| 4. [Argo CD](https://argo-cd.readthedocs.io/en/stable/) — Argo | Sync, health, projects e drift | Fase 4 / Helm e Git |
| 4. [GitHub Actions](https://docs.github.com/en/actions) — GitHub | Workflows, permissões e artefatos | Fase 4 / Git |
| 5. [Terraform](https://developer.hashicorp.com/terraform/docs) — HashiCorp | Plan/state/providers/modules | Fase 6 / cloud e Git |
| 5. [OpenTofu](https://opentofu.org/docs/) — OpenTofu | Comparar governança e compatibilidade IaC | IaC / Terraform |
| 5. [Crossplane](https://docs.crossplane.io/latest/) — Crossplane | Providers, XRD, Compositions e Functions | Fase 8 / CRDs e IaC |
| 6. [AWS documentation](https://docs.aws.amazon.com/) — AWS | Fundamentos e contratos dos serviços | Fase 6 / redes e IAM |
| 6. [IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html) — AWS | Identidades e políticas | Fase 6 / least privilege |
| 6. [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) — AWS | Subnets, routing e isolamento | Fase 6 / CIDR e NAT |
| 6. [EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html) — AWS | Compute, famílias GPU, Spot e EBS | Fase 6 / Linux e custos |
| 6. [ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html) — AWS | Registry e identidade de pull | Supply chain / OCI |
| 6. [EKS](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html) — AWS | Cluster, networking e workload identity | Fase 6 / Kubernetes |
| 6. [Karpenter](https://karpenter.sh/docs/) — Karpenter | NodePool, EC2NodeClass e lifecycle | Fase 6 / EKS e scheduling |
| 6. [Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html) — AWS | Provedor gerenciado de modelos | Gateway / IAM e orçamento |
| 7. [Azure](https://learn.microsoft.com/en-us/azure/) — Microsoft | Fundamentos e serviços | Fase 7 / cloud |
| 7. [Entra ID](https://learn.microsoft.com/en-us/entra/identity/) — Microsoft | Identidade e autorização | Fase 7 / OAuth |
| 7. [Managed identities](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview) — Microsoft | Identidade de workload sem senha distribuída | Fase 7 / Entra |
| 7. [VNet](https://learn.microsoft.com/en-us/azure/virtual-network/) — Microsoft | Rede e isolamento | Fase 7 / CIDR |
| 7. [ACR](https://learn.microsoft.com/en-us/azure/container-registry/) — Microsoft | Registry e acesso | Fase 7 / OCI |
| 7. [AKS](https://learn.microsoft.com/en-us/azure/aks/) — Microsoft | Kubernetes gerenciado, rede e identidade | Fase 7 / Kubernetes |
| 7. [GPU VM sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview) — Microsoft | Hardware e restrições de SKU | GPU / VRAM |
| 7. [Spot VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/spot-vms) — Microsoft | Eviction e disponibilidade | Capacidade / recuperação |
| 8. [CUDA](https://docs.nvidia.com/cuda/) — NVIDIA | Warps, blocos, memória e kernels | Fase 10 / C++ |
| 8. [Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/) — NVIDIA | GPU dentro do runtime | GPU / drivers e containers |
| 8. [Device Plugin](https://github.com/NVIDIA/k8s-device-plugin) — NVIDIA | GPU como extended resource | GPU / Kubernetes |
| 8. [GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/) — NVIDIA | Lifecycle do stack GPU | GPU / operators |
| 8. [DCGM](https://docs.nvidia.com/datacenter/dcgm/latest/) — NVIDIA | Saúde/utilização GPU | Observabilidade / GPU |
| 8. [DCGM Exporter](https://github.com/NVIDIA/dcgm-exporter) — NVIDIA | Métricas GPU em Prometheus | Observabilidade / DCGM |
| 9. [vLLM](https://docs.vllm.ai/en/stable/) — vLLM project | Modelos suportados, KV cache, distribuição, quantização, prefix cache, tool calling, reasoning e structured outputs | Fase 3 / GPU e Transformers |
| 9. [LiteLLM](https://docs.litellm.ai/docs/) — BerriAI | Proxy, routing, retry/fallback, budgets, auth e hooks | Gateway / HTTP e tokens |
| 10. [MCP specification](https://modelcontextprotocol.io/specification/latest) — MCP project | Protocolo, lifecycle, autorização e segurança | Fase 2 / JSON-RPC e HTTP |
| 10. [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk) — MCP project | Implementação e cliente oficiais | Fase 2 / Python |
| 10. [LangGraph](https://docs.langchain.com/oss/python/langgraph/overview) — LangChain | Estado, grafos e checkpoints para comparação | Fase 5 / agentes e falhas |
| 11. [OpenTelemetry](https://opentelemetry.io/docs/) — OpenTelemetry | Context propagation, spans e exportação | Fase 2 / serviços distribuídos |
| 11. [Prometheus](https://prometheus.io/docs/introduction/overview/) — Prometheus | Scrape, PromQL e alertas | Fase 2 / métricas |
| 11. [Grafana](https://grafana.com/docs/grafana/latest/) — Grafana Labs | Dashboards e provisionamento | Fase 2 / PromQL |
| 11. [OpenMetrics](https://openmetrics.io/) — OpenMetrics | Formato e semântica de métricas | Observabilidade / métricas |
| 12. [PostgreSQL](https://www.postgresql.org/docs/) — PostgreSQL Global Development Group | Persistência e consultas | Fase 5 / SQL |
| 12. [pgvector](https://github.com/pgvector/pgvector) — pgvector | Índices vetoriais e distância | RAG / PostgreSQL e embeddings |
| 12. [MongoDB](https://www.mongodb.com/docs/) — MongoDB | Modelo documental para comparação | Dados / modelagem |
| 13. [Kubernetes security](https://kubernetes.io/docs/concepts/security/) — Kubernetes | Defesa em profundidade | Segurança / Kubernetes |
| 13. [OWASP Top 10](https://owasp.org/www-project-top-ten/) — OWASP | Riscos de aplicações | Segurança / HTTP |
| 13. [OWASP API Security](https://api-security.owasp.org/editions/2023/en/0x00-header/) — OWASP | Autorização e abuso de APIs | Segurança / APIs |
| 13. [OWASP GenAI](https://genai.owasp.org/) — OWASP | Prompt injection, tools e dados | Segurança / agentes e RAG |
| 13. [Cosign](https://docs.sigstore.dev/cosign/signing/signing_with_containers/) — Sigstore | Assinar e verificar imagens | Supply chain / OCI |
| 13. [SLSA](https://slsa.dev/) — SLSA | Provenance e integridade de builds | Supply chain / CI |
| 13. [Trivy](https://trivy.dev/) — Aqua Security | Scanner de containers/configuração | Supply chain / imagens |
| 13. [Syft](https://github.com/anchore/syft) — Anchore | SBOM | Supply chain / pacotes |
| 13. [Grype](https://github.com/anchore/grype) — Anchore | Vulnerabilidades de artefatos | Supply chain / SBOM |
| 14. [Kyverno](https://kyverno.io/docs/) — Kyverno | Políticas Kubernetes e audit mode | Fase 9 / admission |
| 14. [OPA](https://www.openpolicyagent.org/docs) — Open Policy Agent | Policy engine e Rego | Fase 9 / autorização |
| 14. [Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/docs/) — OPA Gatekeeper | Admission com constraints | Fase 9 / OPA |
| 15. [OpenCost](https://www.opencost.io/docs/) — OpenCost | Rateio de recursos e limitações | FinOps / Kubernetes e métricas |
| 15. [AWS Cost Management](https://docs.aws.amazon.com/cost-management/latest/userguide/billing-getting-started.html) — AWS | Custos faturados e controle | Fase 6 / conta e billing |
| 15. [Azure Cost Management](https://learn.microsoft.com/en-us/azure/cost-management-billing/) — Microsoft | Billing e orçamento | Fase 7 / subscription |
| 16. [k6](https://grafana.com/docs/k6/latest/) — Grafana Labs | Carga e thresholds | Performance / HTTP |
| 16. [Locust](https://docs.locust.io/en/stable/) — Locust | Carga programável em Python | Performance / Python |
| 16. [Python profiling](https://docs.python.org/3/library/profile.html) — Python Software Foundation | Encontrar hotspots antes de reescrever | Performance / Python |

Retrieval híbrido/reranking têm literatura na lista de papers; não há banco ou
algoritmo vencedor definido. Recursos são materiais de estudo, não dependências
automaticamente instaladas.
