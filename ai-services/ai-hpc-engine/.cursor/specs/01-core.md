# Core types

Status: feito

## Objetivo

Definir os tipos de domínio do engine em Mojo: status/erro, dtype, device, shape, buffer, tensor, model, request e response. Este é o primeiro pacote do engine e a base de tudo o que vier depois.

## Comportamento

- `StatusCode` cobre: `ok`, `invalid_argument`, `not_found`, `already_exists`, `unavailable`, `unimplemented`, `internal`, `cancelled`, `resource_exhausted`.
- Falhas de API levantam `EngineError` tipado (`raises EngineError`), com código + mensagem. Não usar `std::expected`.
- Dtypes de tensor reutilizam o `DType` da stdlib Mojo para o conjunto usado pelo protocolo: `float32`, `float16`, `bfloat16`, `float64`, `int8`/`16`/`32`/`64`, `uint8`/`16`/`32`/`64`, `bool`.
- `Device` distingue `cpu` e `gpu` (portável). Não expor `cuda` como tipo de dispositivo. `index` identifica o acelerador. `enumerate_devices()` sempre inclui CPU; GPU entra quando o runtime Mojo/MAX detectar hardware.
- `Shape` guarda dims `Int`; `numel()` é o produto; dim negativa significa shape dinâmico e `numel()` retorna `-1`. `byte_size(dtype)` falha se houver dim dinâmica ou dtype sem tamanho conhecido.
- `Buffer` possui a memória. Alocação CPU zera e é determinística. Alocação GPU nesta spec levanta `unimplemented`.
- `Tensor.empty` / `zeros` / `from_host` validam `shape × dtype` contra o número de bytes. `zeros` produz buffer todo zero. `from_host` copia bytes do host para um buffer CPU.
- `Model` descreve id, nome, path, backend, `ModelKind` e device.
- `Request` / `Response` carregam o contrato de inferência (prompt, textos, documentos, tensores, geração, scores).

## Fora de escopo

- Kernels GPU, IPC/gRPC/HTTP, backends de modelo, batcher, scheduler.
- Alocação de buffer em device GPU (spec posterior).
- FFI C (`ai_compute.h`).

## Interfaces

Pacote `ai_compute.core` importável com `-I src`.

- `Status`, `StatusCode`, `EngineError`
- `element_byte_size(dtype: DType) raises EngineError -> Int`
- `DeviceKind`, `Device`, `enumerate_devices()`
- `Shape`, `Buffer`, `Tensor`
- `ModelKind`, `Model`
- `GenerationParams`, `Request`, `Response`

Entry: `src/main.mojo` imprime versão e health.

## Ownership e recursos

- `Buffer` e `Tensor` possuem os bytes. Cópias são explícitas (`Copyable` + `.copy()`).
- `from_host` lê um `Span` emprestado e copia para buffer próprio.
- `Device` e `Shape` são valores baratos / implicitamente copiáveis quando os campos permitirem.
- Nenhum recurso GPU nesta spec.

## Execução e hardware

- CPU escalar nesta spec.
- Device `gpu` existe no tipo, mas alocação GPU é `unimplemented`.
- Precisão: igualdade binária em buffers zero e em tamanhos; sem kernels numéricos ainda.

## Critérios de aceite

- [x] `element_byte_size(DType.float32) == 4` e nomes estáveis (`float32`).
- [x] `Shape` rank/numel/`byte_size` batem com o contrato acima, inclusive dim dinâmica e dtype inválido.
- [x] `Tensor.zeros` aloca o número certo de bytes e todos são zero.
- [x] `Device.cpu().label() == "cpu:0"` e `enumerate_devices()` não é vazio.
- [x] `ModelRegistry.register` rejeita id vazio e duplicata; `list()` reflete o registro.
- [x] `mojo run -I src tests/test_core.mojo` passa.
- [x] Código formatado com `mojo format`.

## Testes

- Casos funcionais: dtype size, shape, zeros, device label, registry.
- Casos de erro/borda: shape dinâmica, `from_host` com tamanho errado, alocação GPU, registry id vazio / duplicado / not_found.
- Tolerância numérica: não aplicável (bytes zero).
- Comparação CPU/GPU: não nesta spec.

## Performance

Nenhum ganho exigido. Buffer CPU usa `List[UInt8]` (owner stdlib). Benchmark entra em spec de memória/kernels.

## Notas de toolchain

Mojo 1.0+ estável via `pixi`. APIs: `def`, `raises EngineError`, `TestSuite.discover_tests`, `from std.testing import ...`, destrutor `__deinit__` se necessário. Sem `fn`. Sem xmake/CMake para este código.
