# Objetivo

Diagnosticar falha parcial, timeout e reconciliação sem supor um sistema síncrono.

# Fundamentos

Timeout não comprova que o servidor não executou a ação. Retry precisa de
idempotência, limite e backoff; retries em todas as camadas multiplicam carga.
Partição, réplica atrasada e relógio divergente produzem observações diferentes.
Leader election e consenso não eliminam latência nem falha parcial.

# Como funciona internamente

Kubernetes, Argo CD e Crossplane reconciliam estado observado e desejado em loops.
Readiness pode mudar antes que todos os clientes observem endpoints atualizados.
Filas absorvem picos finitos; quando chegada supera capacidade por tempo suficiente,
latência e memória crescem. Backpressure e load shedding protegem o sistema.

# Relação com nossa arquitetura

MCP/HTTP têm deadlines; workflow atual não repete inferência automaticamente.
vLLM terá fila e limites de concorrência. LiteLLM poderá aplicar retry/fallback,
com orçamento total e sem retry storms. Estado de agentes exigirá checkpoints
e idempotência para tools mutáveis, antes de introduzi-las.

# Laboratório

Execute `tests/test_backends.py` para respostas inválidas/503/limite de tamanho.
Esses testes usam MockTransport e só demonstram comportamento do adaptador.
Depois repita com dependência real no laboratório e capture duração e erros.

# Failure Lab

Compare resposta 503 imediata com conexão que excede deadline. Registre hipótese
sobre execução remota antes de decidir retry. Não use operação mutável nesse teste.

# Troubleshooting

Correlacione timestamps e trace_id; cuidado com relógios. Diferencie fila,
serviço lento e rede. Ausência de logs remotos não prova que a chamada não chegou.

# Production considerations

Documentar consistência de cada dado, replicação/particionamento, locks distribuídos,
detecção de falha, circuit breakers e rate limiting. Não construir consenso próprio.
Locks precisam de fencing/lease quando houver efeitos externos.

# Perguntas de domínio

Quando uma leitura pode ficar obsoleta? Que efeitos um retry duplica? Como detectar
saturação antes de timeout? Qual é a diferença entre indisponibilidade e partição?

# Checklist

- [ ] Testei deadline e resposta inválida e distingui mocks de dependência real.
- [ ] Expliquei idempotência, backpressure e consistência eventual com um componente.
- [ ] Justifiquei onde aplicar retry e qual orçamento total usar.

# Referências

DDIA, Raft, Borg e Dapper na biblioteca de livros/papers; documentação dos controllers.
