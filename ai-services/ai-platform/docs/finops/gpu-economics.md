# Economia de GPU baseada em medições

Sem preços ou capacidade inventados. Registrar região/data/moeda, SKU, modalidade,
tempo provisionado, tempo útil, idle, cold start, tokens e falhas. Separar custo
faturado pelo provedor de rateio interno estimado.

Estimativa de custo/requisição = custo total alocado no intervalo / requisições
concluídas no intervalo. Incluir ociosidade, armazenamento, rede e controle;
não atribuir todo custo à GPU e ignorar plataforma. Para separar input/output
tokens, definir um método de rateio e declarar sua limitação: são fases com
características de compute/memória distintas.

Compare compra/cloud com utilização real, energia, operação e depreciação;
Spot/On-Demand com interrupções, cold start, recarga de modelo e SLO. Quantização
precisa medir qualidade junto da memória e performance. Batching pode melhorar
throughput com pior latência. Scale-to-zero economiza idle e aumenta startup.

Experimento futuro: mesma carga, modelo/revisão e hardware, variando concorrência,
contexto e quantização. Registrar TTFT, ITL, throughput, erros, VRAM e custo.
Não usar a medição de `/health/ready` para dimensionar inferência.
