# Fronteira Rust / Mojo

## Rust possui

- todo tráfego norte-sul e a resposta ao cliente;
- autenticação, autorização, validação, rate limits e tenancy;
- domínio e casos de uso do backend tradicional;
- CRUD, persistência e acesso direto a bancos relacionais, não relacionais e
  vetoriais em fluxos tradicionais;
- transações, mensageria, integrações e observabilidade do produto;
- decisão explícita de invocar ou não o runtime agentic.

## Mojo possui

- agentes, nós, grafo, routing, workflows e orchestration agentic;
- tool calling e execution harness;
- RAG/retrieval agentic, reranking e construção de contexto;
- embeddings, tokenização, inferência e kernels CPU/GPU;
- estado necessário à execução agentic;
- health e transporte estritamente internos.

Rust pode consultar um vector store diretamente em um fluxo convencional. No
fluxo agentic, Mojo possui a estratégia de retrieval/RAG e seus adapters
específicos. Essa distinção evita forçar operações normais do backend a passar
por nós agentic.

O contrato direcional normal é `Rust -> Mojo -> Rust`. Mojo não é acessível ao
cliente e não possui a resposta pública. Eventuais callbacks de tools/dados
devem usar portas internas estreitas e autorizadas, nunca a API pública.
