# Mapa de conhecimento

```mermaid
flowchart TD
  E[AI Platform Engineer] --> S[Sistemas]
  E --> P[Plataforma]
  E --> A[IA]
  S --> L[Linux / processos / memória]
  S --> N[Redes / DNS / TLS]
  S --> C[Containers / OCI / cgroups]
  P --> K[Kubernetes / Helm / scheduling]
  P --> I[Terraform / Crossplane]
  P --> G[GitOps / Argo CD]
  A --> M[LLM / vLLM / GPU]
  A --> R[RAG / dados / avaliações]
  A --> AG[Agentes / MCP / gateway]
  L --> PROD[IA em produção]
  N --> PROD
  C --> PROD
  K --> PROD
  I --> PROD
  G --> PROD
  M --> PROD
  R --> PROD
  AG --> PROD
  PROD --> SRE[SRE / telemetria / incidentes]
  PROD --> FIN[FinOps / GPU / tokens / capacidade]
  PROD --> SEC[Segurança / identidade / isolamento]
```

Exemplo de dependência: antes de diagnosticar Pod vLLM Pending, entender requests,
filtering do scheduler, extended resources, device plugin e capacidade dos nodes.
Antes de interpretar latência de geração, separar fila, prefill, decode e rede.
