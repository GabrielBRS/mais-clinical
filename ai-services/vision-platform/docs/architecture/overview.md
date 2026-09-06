# Arquitetura

`model-training` (Python / pixi) exporta ONNX.
`inference-engine` (Mojo 1.0+ / SIMD / GPU Mojo portável) executa detect/classify/segment.
`vision-runtime` (Rust) orquestra pipeline, tracking e serving.
IPC VPE1 no mesmo framing do ACE1.
