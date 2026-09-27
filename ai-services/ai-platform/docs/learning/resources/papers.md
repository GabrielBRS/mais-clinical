# Papers ligados a experimentos

Resultados de pesquisa dependem de hardware, datasets e implementação. Não são
garantia de ganho na Orzyon. “et al.” indica autoria abreviada; a publicação
vinculada contém a lista completa.

| Publicação / autoria / ano | Conceito e importância | Pré-requisito / experimento |
| --- | --- | --- |
| [Attention Is All You Need](https://arxiv.org/abs/1706.03762) — Ashish Vaswani et al., 2017 | Attention e arquitetura Transformer | Álgebra/ML; explicar dependência de contexto na fase 3 |
| [Efficient Memory Management for Large Language Model Serving with PagedAttention](https://arxiv.org/abs/2309.06180) — Woosuk Kwon et al., 2023 | KV cache e gestão de memória de serving | Attention/GPU; variar contexto e concorrência no vLLM |
| [Orca: A Distributed Serving System for Transformer-Based Generative Models](https://www.usenix.org/conference/osdi22/presentation/yu) — Gyeong-In Yu et al., 2022 | Scheduling de inferência por iteração | Transformers/filas; comparar carga concorrente |
| [Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks](https://arxiv.org/abs/2005.11401) — Patrick Lewis et al., 2020 | Recuperação acoplada à geração | NLP/retrieval; avaliar groundedness após retrieval real |
| [Dense Passage Retrieval for Open-Domain Question Answering](https://arxiv.org/abs/2004.04906) — Vladimir Karpukhin et al., 2020 | Dense retrieval e relevância | Embeddings; comparar lexical/dense no mesmo dataset |
| [ReAct: Synergizing Reasoning and Acting in Language Models](https://arxiv.org/abs/2210.03629) — Shunyu Yao et al., 2022 preprint | Raciocínio e ações intercalados | LLM/tools; comparar com workflow determinístico, medir custo e falhas |
| [In Search of an Understandable Consensus Algorithm](https://raft.github.io/raft.pdf) — Diego Ongaro, John Ousterhout, 2014 | Consenso e eleição de líder | Sistemas distribuídos; estudar falha de node sem reimplementar produção |
| [Large-scale cluster management at Google with Borg](https://research.google/pubs/large-scale-cluster-management-at-google-with-borg/) — Abhishek Verma et al., 2015 | Alocação e scheduling em clusters | Linux/containers; explicar constraints e utilização |
| [Dapper, a Large-Scale Distributed Systems Tracing Infrastructure](https://research.google/pubs/dapper-a-large-scale-distributed-systems-tracing-infrastructure/) — Benjamin H. Sigelman et al., 2010 | Tracing e causalidade entre serviços | RPC/observabilidade; correlacionar spans no workflow |

Quantização, speculative decoding, reranking e inferência distribuída serão
aprofundados ao escolher experimentos de hardware/modelo, sem preencher a lista
com papers não utilizados.
