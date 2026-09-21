# ADR 0002 — Rust ingress, Mojo host e orquestração Python

Status: aceito

## Contexto

Separar backend tradicional e backend agentic em aplicações independentes cria
duplicação de domínio, dados, autenticação, operação e ownership da resposta.
Também força escolhas prematuras: um backend convencional pode ganhar agentes,
e um produto agentic continua precisando de fluxos convencionais.

## Decisão

O AI Native Application Server é um único produto composto por dois processos:

- Rust é o Application Server completo e o único ingress público;
- Python `ai_orchestrator` é o contrato que define o sistema agentic;
- Mojo é o runtime interno que embute CPython, carrega e conserva os objetos
  desse contrato e executa a implementação,
  invocado somente por casos de uso Rust agentic.

As seguintes invariantes são obrigatórias:

1. clientes nunca acessam Mojo diretamente;
2. Rust autentica, autoriza e valida antes de qualquer chamada agentic;
3. um fluxo tradicional não atravessa Mojo;
4. agentes, nós, graph, orchestration, workflows, tools e RAG/retrieval
   pertencem ao pacote Python `ai_orchestrator`;
5. CRUD, domínio de negócio, transações, persistência e integrações tradicionais
   pertencem a Rust;
6. Rust mantém ownership da resposta pública e dos erros expostos ao cliente;
7. o transporte Rust/Mojo é interno e substituível;
8. a indisponibilidade do Mojo afeta capacidades agentic, não a readiness dos
   fluxos tradicionais.
9. Mojo carrega Python com `Python.import_module()` no mesmo processo; não usa
   subprocesso e não reimplementa agentes ou grafos;
10. cada módulo Python possui loader Mojo homólogo gerado, e o registro Mojo
    mantém os módulos carregados durante a vida do processo.

## Consequências

Todo deploy inclui Rust e o runtime Mojo/Python, mas somente Rust publica porta.
Casos de uso agentic recebem explicitamente a porta `AgentRuntime`; outros casos
de uso não conhecem Mojo nem Python.

`Python.import_module()` é uma operação de startup/runtime. Ela não converte
automaticamente Python em código nativo Mojo; trechos que exigirem aceleração
devem ser implementados como kernels Mojo explícitos sem duplicar o contrato.
