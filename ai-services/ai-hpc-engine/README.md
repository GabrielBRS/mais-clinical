# ai-compute-engine

Motor de inferência em **Mojo 1.0+**. É o primeiro dos três processos da
plataforma: os três falam entre si por **IPC** (unix socket, framing `ACE1`).
gRPC e HTTP usam o mesmo contrato quando essa camada existir.

Toolchain: **Mojo CLI** + **pixi**. Todo o código do projeto é `.mojo`.
Não há C++/CUDA neste repositório.

```mojo
from ai_compute.core import Tensor, Shape

def main() raises:
    var tensor = Tensor.zeros(Shape(2, 2), DType.float32)
    print(tensor.nbytes())
```

## Stack

| Camada | Agora | Depois |
| --- | --- | --- |
| Linguagem | Mojo 1.0+, `def`, pacotes com `__init__.mojo` | kernels GPU portáveis, especialização NVIDIA/AMD se medida |
| Build | `pixi run mojo`, `mojo build`, `mojo format` | `mojo precompile` quando o pacote crescer |
| Qualidade | `std.testing` + `TestSuite` | fuzz do protocolo na spec de transport |
| Erros | `raises EngineError` (código + mensagem) | erros alocação-free em kernels GPU |
| Dados | `List`, `Span`, `DType` da stdlib | layouts / tensores GPU |
| GPU | tipo `Device.gpu`, alocação ainda `unimplemented` | kernels Mojo portáveis |

## Build

Requer [Pixi](https://pixi.sh/) e Mojo 1.0+ (canal estável Modular).
O binário do Pixi fica em `~/.pixi/bin`; se `pixi` não for encontrado, abra um
terminal novo ou rode `source ~/.bashrc`.

```bash
pixi install
pixi run test
pixi run build
./build/ai-compute
```

Ou direto:

```bash
pixi run mojo run -I src tests/test_core.mojo
pixi run mojo run src/main.mojo
pixi run mojo build src/main.mojo -o build/ai-compute
```

## Layout

| Caminho | Conteúdo |
| --- | --- |
| `src/main.mojo` | entrypoint |
| `src/ai_compute/core/` | status, erro, dtype, device, shape, buffer, tensor, model |
| `src/ai_compute/runtime/` | registry de modelos |
| `src/ai_compute/telemetry/` | health/versão |
| `tests/` | `TestSuite` Mojo |
| `.cursor/specs/` | contratos |
