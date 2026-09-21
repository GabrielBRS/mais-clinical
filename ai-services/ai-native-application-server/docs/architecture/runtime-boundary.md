# Fronteira Rust / Mojo

## Rust possui

- todo tráfego norte-sul e a resposta ao cliente;
- autenticação, autorização, validação, rate limits e tenancy;
- domínio e casos de uso do backend tradicional;
- CRUD, persistência e acesso direto a bancos relacionais, não relacionais e
  vetoriais em fluxos tradicionais;
- transações, mensageria, integrações e observabilidade do produto;
- decisão explícita de invocar ou não o runtime agentic.

## Python `ai-agent-contract` define

- agentes, nós, grafo, routing, workflows e orchestration agentic;
- tool calling e execution harness;
- RAG/retrieval agentic, reranking e construção de contexto;
- contratos e estratégias de embeddings, tokenização e inferência;
- estado necessário à execução agentic;
- adapters de modelos e estado necessários à execução agentic.

## Mojo possui

- lifecycle do CPython embutido;
- um loader homólogo para cada módulo Python;
- carga eager via `Python.import_module()` e registro de `PythonObject` mantido
  durante a vida do processo;
- execução do composition root e sistema próprio de runtime;
- kernels Mojo nativos para hot paths que forem medidos e implementados;
- health e transporte estritamente internos entre Rust e Python;
- tradução mecânica do contrato interno, sem segunda definição da lógica agentic.

Rust pode consultar um vector store diretamente em um fluxo convencional. No
fluxo agentic, o contrato Python define a estratégia de retrieval/RAG e seus
adapters específicos. Mojo carrega e executa essa definição. Essa distinção
evita forçar operações normais do backend a passar por nós agentic.

O contrato direcional normal é `Rust -> Mojo -> Python -> Mojo -> Rust`. Mojo e
Python não são acessíveis ao cliente e não possuem a resposta pública.

O carregamento acontece no startup de `agentd`: CPython continua responsável
por executar os objetos Python. Isso reduz descoberta e composição repetidas,
mas não equivale a compilar Python automaticamente para Mojo. Código realmente
hot deve ganhar kernel Mojo nativo, chamado pelo runtime, quando a medição pedir.
