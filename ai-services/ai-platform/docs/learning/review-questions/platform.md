# Perguntas sem gabarito embutido

Cada grupo progride de básico a intermediário, avançado, incidente e arquitetura.
Registre respostas próprias e evidências. Consulte referências em arquivo separado.

## Linux, rede e containers

1. Qual a diferença entre processo e imagem?
2. Como namespace e cgroup se complementam?
3. Como DNS, TCP e TLS influenciam latência HTTP?
4. O processo escuta uma porta, mas o cliente não conecta: quais hipóteses testar?
5. Como definir fronteiras de rede e identidade para serviços de plataforma?

## Kubernetes, Helm e GitOps

1. O que é um Pod?
2. Por que requests e limits diferem?
3. Como filter/score/bind e taints participam do scheduling?
4. Um Pod vLLM com GPU fica Pending: quais eventos e recursos observar?
5. Como dividir Spot/On-Demand e manter rollback sob reconciliação GitOps?

## MCP, RAG e agentes

1. O que `tools/list` retorna?
2. Por que erro de tool pode vir com HTTP 200?
3. Como preservar autorização de usuário ao acessar documento via agente?
4. Retrieval retorna documento não autorizado: onde conter e investigar?
5. Quando workflow determinístico é melhor que loop ou multi-agent?

## Serving, GPU e performance

1. O que TTFT mede?
2. Como concorrência/contexto afetam KV cache?
3. Como distinguir prefill/decode/fila e custo de comunicação entre GPUs?
4. Latência sobe com GPU pouco utilizada: quais hipóteses além de compute?
5. Como escolher runtime sem inventar scores ou extrapolar um benchmark?

## IaC, segurança, SRE e FinOps

1. O que existe no state Terraform?
2. Como evitar que Terraform e Crossplane controlem o mesmo recurso?
3. Como definir SLI de ferramenta se HTTP 200 também representa erro?
4. Cloud continua cobrando após remover workload: o que inspecionar?
5. Como projetar ambientes, aprovação de custos, isolamento, backup e SLO?

Rust, C++, CUDA e demais domínios da matriz terão perguntas específicas junto
dos laboratórios de fase 10; não estão avaliados nesta entrega.
