# ADR-0003 — MCP real, leitura controlada e recuperação lexical

Status: adotado para a primeira entrega.

## Context

Precisamos de tools úteis, testáveis e seguras sem depender de inferência.

## Decision

SDK oficial MCP, transporte Streamable HTTP, três servidores lógicos montados
na API. Tools são allowlisted e somente leitura; Kubernetes só lista deployments
do namespace fixado. Prometheus aceita nomes de consultas controladas. Corpus
é um snapshot Markdown limitado a 200 arquivos de 100 KB, sem paths externos.

## Alternatives considered

REST exige menos lifecycle e continua adequado à UI. SDK interno reduz overhead,
mas não ensina interoperabilidade MCP. MCP adiciona negociação, schemas e cliente
comum; não substitui APIs. PostgreSQL/pgvector é candidato ao RAG futuro, mas
introduzi-lo agora exigiria embeddings e avaliação que esta entrega não possui.

## Consequences

Teste real de initialize/list/call via SDK e TCP. Recuperação lexical tem baixa
qualidade para sinônimos; não chamamos isso de RAG vetorial completo. As três
instâncias compartilham token/processo/ServiceAccount: não há isolamento entre
servidores lógicos. Separação física e OAuth são necessários antes de produção.

## Risks

Documento pode conter prompt injection. Não expor tools mutáveis nem dados
sensíveis; restrições determinísticas têm prioridade sobre instruções ao modelo.
Token compartilhado impede atribuir ações a usuários distintos.

## Revisit conditions

Dados privados, múltiplos tenants, necessidade de autorização por tool, maior
corpus, precisão insuficiente ou escala independente.
