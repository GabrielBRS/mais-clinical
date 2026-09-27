# Orzyon AI Platform

A plataforma usa Kubernetes para reconciliar workloads, Helm para empacotar
configuração e MCP para expor ferramentas de leitura controlada. O gateway
LiteLLM separa o cliente do provedor de inferência. vLLM precisa de hardware
compatível e seus benchmarks devem registrar modelo, GPU e configuração.

Um Pod Pending deve ser investigado pelos eventos e pelas restrições de
scheduling: requests, capacidade, afinidade, taints e tolerations. Uma GPU
ausente não pode ser validada por um mock de inferência.

Não registrar secrets, prompts ou documentos privados na telemetria.
Recursos pagos exigem aprovação humana prévia. Git descreve o estado desejado.
