# Leitura de código-fonte

Repositórios oficiais abaixo são pontos de entrada, não instruções para instalar
todos os projetos. Diretórios são orientações de leitura e podem mudar entre
releases; compare com a tag efetivamente usada. Não clonamos esses repositórios.

| Projeto / papel | Onde começar e padrão a observar | Uso / dificuldade |
| --- | --- | --- |
| [Kubernetes](https://github.com/kubernetes/kubernetes) — orquestração | `pkg/scheduler`, `pkg/controller`, `pkg/kubelet`; work queues e reconciliação | Alvo local / advanced |
| [Karpenter](https://github.com/kubernetes-sigs/karpenter) — capacidade | `pkg/controllers`; provisionamento por constraints | Estudo fase 6 / advanced |
| [AWS provider Karpenter](https://github.com/aws/karpenter-provider-aws) — integração EC2 | `pkg/providers`, `pkg/controllers`; separar provider de lógica genérica | Estudo fase 6 / advanced |
| [Crossplane](https://github.com/crossplane/crossplane) — control plane extensível | `internal/controller`, `apis`; controllers e API declarativa | Estudo fase 8 / advanced |
| [Argo CD](https://github.com/argoproj/argo-cd) — GitOps | `controller`, `reposerver`, `server`; separar renderização e reconciliação | Manifests preparados / advanced |
| [Helm](https://github.com/helm/helm) — packaging | `pkg/chart`, `pkg/engine`, `pkg/action`; valores/render/release | Uso direto / intermediate |
| [vLLM](https://github.com/vllm-project/vllm) — serving | `vllm/entrypoints`, `vllm/v1`; API versus scheduler/engine | Perfil opcional / advanced |
| [LiteLLM](https://github.com/BerriAI/litellm) — gateway | `litellm/proxy`, `litellm/router.py`; adapters e roteamento | Perfil opcional / intermediate |
| [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk) — protocolo | `src/mcp/client`, `src/mcp/server`, `examples`; lifecycle e transporte | Uso direto / intermediate |
| [MCP specification](https://github.com/modelcontextprotocol/modelcontextprotocol) — contratos | `schema`, `docs`; evolução de protocolos | Referência direta / intermediate |
| [LangGraph](https://github.com/langchain-ai/langgraph) — workflows stateful | `libs/langgraph`; grafos e checkpoints | Comparação futura / intermediate |
| [OpenTelemetry Python](https://github.com/open-telemetry/opentelemetry-python) — instrumentação | `opentelemetry-api`, `opentelemetry-sdk`; API versus implementação/exporter | Uso direto / intermediate |
| [Prometheus](https://github.com/prometheus/prometheus) — séries temporais | `scrape`, `promql`, `tsdb`; ingestão, consulta e armazenamento | Compose / advanced |
| [Grafana](https://github.com/grafana/grafana) — visualização | `pkg`, `public`; backend e frontend de dashboards | Compose / advanced |
| [OpenCost](https://github.com/opencost/opencost) — rateio | `pkg`; reconciliação de custos com métricas | Estudo futuro / intermediate |
| [NVIDIA Device Plugin](https://github.com/NVIDIA/k8s-device-plugin) — recursos GPU | `cmd`, `internal`; descoberta/alocação de dispositivos | Estudo futuro / advanced |
| [NVIDIA GPU Operator](https://github.com/NVIDIA/gpu-operator) — lifecycle GPU | `controllers`, `api`; dependências e reconciliation | Estudo futuro / advanced |

Exercício: escolha um componente, trace uma requisição da entrada ao efeito e
explique como timeout/cancelamento aparecem. Clone opcional de um único projeto:

```sh
git clone --depth 1 https://github.com/modelcontextprotocol/python-sdk.git
```

O comando baixa código para estudo; não concede permissão para executá-lo
cegamente nem altera dependências do projeto.
