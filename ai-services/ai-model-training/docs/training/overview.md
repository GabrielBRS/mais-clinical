# Training

O engine executável atual é um scaffold determinístico de CPU com modelo dummy.
Os smokes de full SFT, LoRA e QLoRA exercitam composição de recipes, checkpoint,
adapter e exportação, mas não representam PyTorch ou kernels de GPU.

Recipes e portas de código para continued pretraining, DPO, GRPO, reward model,
DDP, FSDP, DeepSpeed e multi-node estão preservadas. Esses fluxos são pendentes
de backend real, testes de correção e validação no hardware correspondente.

Todo fluxo operacional começa no binário Mojo. Launchers de cluster são adapters
de infraestrutura e também encaminham ao CLI Mojo.
