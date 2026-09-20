# inference-engine

Motor de inferência em **Mojo 1.0+**. Composition root em
`vision.bootstrap`, detector/NMS/IPC em pacotes Mojo.

Toolchain: **Mojo CLI** + **pixi**. Todo o código do engine é `.mojo`.
Não há C++/CUDA neste diretório.

```bash
pixi install
pixi run test
pixi run build
./build/vision-inference-engine
```

GPU: kernels Mojo portáveis em `src/vision/gpu/kernels/`. Especialização
NVIDIA/AMD só depois de medida. `device_count()` é 0 até o host ligar
`DeviceContext`.
