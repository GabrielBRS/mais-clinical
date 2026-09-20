# Core types, preprocess, NMS e detector

Status: feito

## Objetivo

Definir os tipos de domínio do inference-engine em Mojo e os caminhos CPU que os testes atuais exercitam: imagem/tensor, resize/gray/bgr/normalize, IoU/NMS, blob detector e framing IPC VPE1.

## Comportamento

- `StatusCode` cobre: `ok`, `invalid_argument`, `not_found`, `already_exists`, `unavailable`, `unimplemented`, `internal`, `cancelled`, `resource_exhausted`.
- Falhas de API levantam `VisionError` tipado (`raises VisionError`), com código + mensagem. Não usar `std::expected`.
- `Device` distingue `cpu` e `gpu` (portável). Não expor `cuda` como tipo de dispositivo.
- `Image` é HxWxC em bytes `UInt8` contíguos. `zeros` e `from_rgb` validam dimensões e tamanho do buffer.
- `Tensor` é float32 no host, shape de rank 1..8, dims positivas. `zeros` / `from_host` validam `numel`.
- `Box` é xywh + score + class_id. `iou` usa interseção sobre união; caixas disjuntas dão 0.
- Preprocess: `resize_nearest`, `rgb_to_gray` (BT.601 299/587/114), `rgb_to_bgr`, `normalize_nchw` com scale/bias SIMD.
- `nms` ordena por score desc e suprime sobreposição acima do limiar de IoU.
- `BlobDetector` converte RGB→gray, flood-fill de pixels ≥128, filtra área/score, aplica NMS.
- IPC VPE1: magic `VPE1`, versão 1, header little-endian de 20 bytes, `payload_size` tem de bater.

## Fora de escopo

- HTTP/gRPC reais (flags `serving.*_bound()` permanecem false).
- TensorRT/ONNX/libtorch (backends registrados, `available() == false` excepto identity custom).
- Decode JPEG/PNG/vídeo e câmera/RTSP.
- Alocação persistente de tensores no device GPU (resize GPU entra em spec posterior se medida).

## Interfaces

Pacote `vision` importável com `-I src`.

- `Status`, `StatusCode`, `VisionError`
- `Device`, `enumerate_devices`
- `Box`, `Detection`, `Track`, `iou`
- `Image`, `Tensor`
- `preprocess.resize_nearest`, `rgb_to_gray`, `rgb_to_bgr`, `normalize_nchw`
- `postprocess.nms`, `filter_score`, `decode_boxes`
- `inference.BlobDetector`
- `ipc.encode_frame` / `decode_frame`
- `cpu.simd.scale_bias`, `dot`, `axpy`, `nrm2`

Entry: `src/main.mojo` sobe o composition root (IPC unix socket).

## Ownership e recursos

- `Image` e `Tensor` possuem os buffers. Cópias são explícitas (`Copyable` + `.copy()`).
- `from_rgb` / `from_host` leem `Span` ou `List` emprestados e copiam para buffer próprio.
- Unix socket possui o fd e faz unlink do path de bind no destrutor.
- Ponteiros raw só no FFI do socket e no kernel GPU, isolados.

## Execução e hardware

- CPU escalar para detector/NMS/resize de teste.
- SIMD (`SIMD[DType.float32, 8]`) em `scale_bias` / `dot` / `axpy`.
- Device `gpu` existe no tipo. Kernel Mojo de resize é portável; sem acelerador o host usa CPU.
- Precisão: igualdade binária em bytes/boxes inteiros; IoU e normalize usam tolerância frouxa só se necessário.

## Critérios de aceite

- [x] `Image.zeros(4, 4, 3).nbytes() == 48` e `rgb_to_bgr` troca R/B.
- [x] `iou` de caixas sobrepostas > 0.5 e de caixas longe < 0.01; NMS com limiar 0.5 mantém 2 de 3.
- [x] Blob 12×12 branco em 32×32 RGB é detectado com w,h ≥ 8.
- [x] Frame VPE1 health round-trip preserva type, request_id e payload.
- [x] `mojo run -I src tests/test_*.mojo` passa.
- [x] Código formatado com `mojo format`.
- [x] Sem C++/CUDA/xmake/uv no inference-engine nem no treino.

## Testes

- Casos funcionais: zeros, resize, gray, bgr, normalize, iou, nms, blob, ipc encode/decode, SIMD scale_bias/dot.
- Casos de erro/borda: shape inválida, buffer com tamanho errado, magic IPC inválido, payload_size divergente.
- Tolerância numérica: gray BT.601 (pixel vermelho 200,10,10 → gray ≥ 50).
- Comparação CPU/GPU: não exigida nesta spec (sem acelerador obrigatório).

## Performance

Nenhum ganho exigido nesta migração. Benches em `benchmarks/` exercitam preprocess e detector. Medir antes de especializar NVIDIA/AMD.

## Notas de toolchain

Mojo 1.0+ estável via `pixi`. APIs: `def`, `raises VisionError`, `TestSuite.discover_tests`, `from std.testing import ...`. Sem `fn`. Sem xmake/CMake/uv para este código.
