# Arquitetura

`prepare → train → evaluate → export → publish`.

Configs em `configs/` são fragments. Recipes só fazem `extends`.
O treino GPU entra no mesmo `training/` no lugar do `DummyModel`.
