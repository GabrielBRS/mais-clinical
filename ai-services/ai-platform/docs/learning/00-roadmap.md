# Currículo e roadmap de execução

Não confundir arquivo criado com competência dominada. Cada evidência deve
registrar quem executou, comando, versão, resultado e diagnóstico de uma falha.
O roadmap autorizado é o da seção 100; autorização posterior permite trabalhar
com o material disponível apesar da ausência do texto da seção 101.

| Fase | Estudo e entrega | Critério de saída |
| --- | --- | --- |
| 0 | Fundamentos, dependências, ADRs, arquitetura e referências | Outro engenheiro inicia o projeto a partir do README |
| 1 | Containers, kind, objetos Kubernetes, Helm, probes e RBAC | Deploy real, falha diagnosticada e rollback reproduzido |
| 2 | Prometheus/Grafana/OTel e três MCPs | Dashboards com dados reais, trace e falha de tool identificados |
| 3 | Gateway, vLLM, memória e benchmarks | Inferência real e TTFT/ITL/throughput medidos em hardware identificado |
| 4 | Argo CD, CI e supply chain | CI remota passa; drift observado; rollback via Git |
| 5 | RAG e agentes | Corpus representativo, avaliação, ACL e workflow rastreado |
| 6 | AWS, Terraform, EKS, Karpenter, GPU e Spot | Aprovação de custo + criação/diagnóstico/remoção reais |
| 7 | Azure, AKS e comparação | Mesma evidência e exceções documentadas |
| 8 | Crossplane e API interna | Ownership separado, reconciliação e ciclo de vida testados |
| 9 | SRE, FinOps, políticas e capacity planning | Incidentes e decisões sustentados por métricas reais |
| 10 | Rust, C++ e CUDA | Experimento pequeno com hipótese e benchmark justificando uso |

A entrega atual é uma base transversal: parte das fases 0–2, workflow inicial
da fase 5 e artefatos preparatórios da fase 4. Ela não encerra essas fases.
Leia `docs/validation.md` para distinguir IMPLEMENTED e testes executados.

## Ordem de leitura

1. [Mapa](knowledge-map.md), [matriz](skill-matrix.md), README e ADRs.
2. [Módulo local](01-local-platform.md) e labs 001–005.
3. [MCP e observabilidade](13-mcp-observability.md), labs 009/010/012.
4. [Sistemas distribuídos](distributed-systems.md).
5. Referências oficiais; depois código-fonte e papers ligados ao experimento.
6. Serving/RAG/cloud só depois de medir e dominar os pré-requisitos anteriores.

Os demais módulos serão materializados com seus laboratórios; não criamos vinte
arquivos vazios para sugerir currículo concluído. Inventário de labs futuros
fica em `labs/README.md`.
