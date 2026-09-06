# Arquitetura

Hexagonal. Domain e use cases não conhecem FastAPI, gRPC ou ACE1.
Adapters implementam ports. `AppContainer.build()` é o composition root.
