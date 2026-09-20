# vision-platform

Plataforma de visão: treino (Python/pixi), runtime de pipeline (Rust) e
**inference-engine em Mojo 1.0+**. Os três falam **IPC VPE1**
(mesmo layout do ACE1, magic `VPE1`). HTTP e gRPC expõem o contrato em
`proto/`.

| Processo | Stack | Bind default |
| --- | --- | --- |
| inference-engine | Mojo 1.0+ + pixi (CPU SIMD, GPU Mojo portável) | IPC `/tmp/vision-inference.sock`, HTTP 8083, gRPC 50054 |
| vision-runtime | Rust | HTTP 8084, gRPC 50055 |
| model-training | Python / pixi | recipes em `model-training/recipes/` |

Não há C++/CUDA neste repositório. Kernels de acelerador são Mojo.

## Build

Requer [Pixi](https://pixi.sh/) e Mojo 1.0+ (canal estável Modular).
Rode os comandos **na raiz** `vision-platform/` (não precisa de `just`).

```bash
pixi run test
pixi run build
```

Motor Mojo só:

```bash
pixi run test-engine
pixi run build
```

Treino só:

```bash
pixi run test-train
```

Ou, já dentro de um subprojeto:

```bash
cd inference-engine && pixi run test && pixi run build
cd ../model-training && pixi run test
```
