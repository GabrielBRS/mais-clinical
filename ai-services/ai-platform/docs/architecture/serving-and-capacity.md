# Serving, memória e capacidade — metodologia

Estado: DOCUMENTED ONLY para medições GPU. Perfil vLLM/LiteLLM existe em Compose,
mas nenhuma inferência GPU foi executada nesta máquina.

O scheduler Kubernetes aloca recursos `nvidia.com/gpu` publicados por device
plugin; label/toleration apenas participa da elegibilidade. GPU Operator pode
gerir partes do stack, com responsabilidades que precisam combinar com imagem
do node/driver. Em EKS, Karpenter observa demandas e provisiona capacidade;
não substitui plugin nem garante estoque/quotas Spot.

Memória de inferência inclui pesos, KV cache, ativações/workspaces e overhead.
Contexto/concorrência aumentam uso de KV, mas arquitetura, dtype, paralelismo,
quantização e otimizações mudam o perfil. Fórmula simplificada só serve como
hipótese, nunca como capacidade garantida. Medir VRAM e OOM reais.

## Protocolo de experimento

Fixar dataset, seed quando suportado, revisão de modelo, runtime/digest,
hardware/VRAM/interconnect, contexto, quantidade de tokens, concorrência,
warmup e duração. Separar prefill, decode, fila e transferência. Registrar
requisições falhas/canceladas e o custo provisionado durante warmup/idle.

Variar uma dimensão por vez: contexto, concorrência, tamanho do modelo,
memory utilization, quantização. Comparar p50/p95/p99, TTFT, ITL, throughput,
tokens/s, VRAM, GPU utilization e erros. Não apresentar tempo até headers HTTP
como TTFT; é necessário observar o primeiro token da stream.

## Matriz de decisão sem scores inventados

| Dimensão | Evidência necessária para cada runtime candidato |
| --- | --- |
| Modelos | Arquitetura e recurso suportados na versão fixada |
| Hardware | Driver/CUDA/device/interconnect compatíveis |
| Performance | Mesmo dataset e harness, warmup e percentis |
| Operação | Startup, cache, graceful shutdown, rollback e recuperação |
| Distribuição | Tensor/pipeline/expert parallelism quando suportado; custo de comunicação |
| Observabilidade | Métricas úteis, trace/context e labels controladas |
| Custo | Faturamento real ou estimativa com método explícito |

Candidatos a investigar: vLLM (inicial), TGI, Triton, TensorRT-LLM e llama.cpp
para cenários locais/edge pertinentes. Não há vencedor universal declarado.
Data parallelism replica trabalho/modelo; tensor e pipeline dividem partes
da execução; expert parallelism depende da arquitetura. Não provisionar GPUs
extras apenas para preencher uma tabela.
