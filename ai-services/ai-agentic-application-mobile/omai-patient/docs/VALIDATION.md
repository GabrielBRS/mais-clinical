# Validação do protótipo

Ambiente: Windows, Qt 6.8.4, C++20, MSVC 19.51, configuração Release.

- Compilação CMake/Ninja concluída, incluindo compilação dos componentes QML.
- Qt Test: **7 resultados aprovados, 0 falhas**, incluindo inicialização/finalização. Cinco cenários cobrem autenticação demonstrativa e navegação, avaliação e histórico, urgência e dose, consulta e privacidade, e os estados de verificação de prescrição.
- Captura nativa de **42 estados de tela**, cobrindo 39 rotas e três repetições em tema escuro.
- Captura adicional das mesmas rotas a **360 × 800 e texto em 130%** para inspeção de acessibilidade visual. A configuração padrão usa 430 × 900.
- Revisão visual do conjunto de telas e inspeção detalhada de início, chat, prescrição, perfil clínico e tema escuro. Correções de margens, recorte de ícones e ajuste das sugestões de conversa.
- Nenhum erro QML, ReferenceError, TypeError ou ciclo de binding encontrado no log final de renderização.

Reproduzir:

```powershell
pixi run build
pixi run test
pixi run smoke
pixi run smoke-compact
```

Resultados de testes: `build/test-results.txt`. Capturas BMP: `build/screenshots` e `build/screenshots-compact`. Diagnósticos: `build/runtime.log`.

Não validado: APK/emulador/aparelho Android, iOS, TalkBack real, backend, segurança criptográfica, assinatura digital real, IA real, videochamada ou integração com notificações. Esses itens são simulados ou contratos de extensão, conforme README.
