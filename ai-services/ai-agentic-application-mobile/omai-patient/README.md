# OMAI Patient

Protótipo nativo de saúde em **Qt 6.8 / Qt Quick / QML e C++20**. As 20 áreas do briefing estão conectadas, com telas adicionais de detalhe. Não usa Compose, WebView ou Kotlin para a interface ou regras do protótipo.

## Executar no Windows

Pré-requisitos: Pixi e Visual Studio com o workload C++ Desktop. O script reconhece a instalação atual de Visual Studio 18 Community; ajuste `scripts/build.cmd` para outro kit.

```powershell
pixi install
pixi run configure
pixi run build
pixi run test
pixi run start
```

O Pixi fixa as dependências em `pixi.lock`. Abra **CMakeLists.txt da raiz** no Qt Creator para usar outro SDK Qt 6.8+. O template Android Studio original em `app/` foi preservado como referência; ele não inicia a nova interface. O projeto principal agora é o CMake da raiz.

## Roteiro da demonstração

1. Splash → quatro páginas de apresentação → Entrar → **Explorar demonstração**. O formulário também aceita um e-mail fictício válido e senha de seis caracteres; não autentica em servidor.
2. Início → Conversar com a OMAI → dor de cabeça há 3 dias → localização → intensidade → pergunta sobre sinais de alerta → resumo.
3. Salvar no histórico → agendar consulta → entrar na sala simulada → encerrar chamada → cofre de prescrições.
4. Prescrição digital → verificar autenticidade. Experimente os cenários válida, expirada, revogada, assinatura inválida e um identificador desconhecido.
5. Início → Exames → hemograma → perguntar à OMAI sobre este exame.
6. Perfil → Privacidade → Clínica OMAI → revogar → histórico de acesso.
7. Perfil → Preferências → modo escuro e tamanho do texto.

Também é possível registrar/desfazer uma dose, ativar/desativar o lembrete simulado, reagendar/cancelar consulta, filtrar registros, explorar documentos e consultar o perfil clínico. Alt+← volta à tela anterior no desktop.

## Estrutura

```text
src/main.cpp                         Inicialização Qt
src/presentation/viewmodels/        Estado observável e comandos C++
src/application/services/           Contratos de inferência independentes de fornecedor
src/domain/                         Relato, origem e contratos de prescrição
src/infrastructure/storage/         Repositório de dados fictícios
src/infrastructure/crypto/          Contrato de verificação assíncrona
qml/screens/                        Apresentação e composição das telas
qml/components/                     Design system reutilizável
qml/theme/                          Cores, espaçamento, tipografia e movimento
assets/mock.json                    Conteúdo fictício, rotas e metadados
tests/                              Testes dos fluxos e estados C++
```

O estado da jornada fica em C++, e QML apresenta propriedades e dispara comandos. Preferências visuais locais pertencem ao tema. Os componentes possuem nomes acessíveis, navegação por teclado e alvos de toque amplos. O texto pode ser ampliado até 130%; listas e detalhes rolam. O estilo usa superfícies claras, verde profundo, ícones vetoriais e um símbolo OMAI abstrato.

## Android e iOS

No Qt Creator, configure um kit **Qt 6.8+ para Android**, JDK, Android SDK e o NDK compatível com a versão escolhida do Qt. Abra o CMake da raiz, selecione o kit e faça Build/Run em um aparelho ou emulador. O empacotamento é gerado pelo Qt (`androiddeployqt`); não use o `gradlew` do template legado para esta aplicação. Nenhum bridge próprio Java/Kotlin é necessário para o protótipo. Não foi produzido ou validado um APK nesta entrega.

Para iOS, use um kit Qt para iOS com Xcode em macOS. A arquitetura evita dependências Android no domínio. Compilação iOS não validada.

## Limites intencionais

- Todos os dados são fictícios. O relógio da demonstração é 26/09/2026. Não inserir dados reais.
- A conversa é um roteiro determinístico, sem modelo de IA. A lista de sinais de alerta é exemplificativa e não constitui um algoritmo clínico.
- Não há diagnóstico, prescrição real, atendimento humano, chamada de vídeo, captura de câmera/microfone ou upload. O anexo usa um documento de exemplo.
- Login, conta, biometria, passkey, 2FA e bloqueio automático não oferecem segurança real. Integrações futuras são explicitadas na interface.
- QR Code codifica `OMAI-2026-00842`; a validação é simulada, não usa certificados reais nem consulta servidor. O contrato futuro separa assinatura, integridade, validade, timestamp, cadeia de confiança e revogação. Criptografia de conteúdo não substitui assinatura.
- As mudanças duram a sessão. SQLite, cache, rede, notificações de sistema, sincronização e execução local/cloud de IA são próximos adaptadores, não serviços implementados.
- A tela original do exame é uma prévia fictícia nativa, não um PDF real.

O build usa a [integração oficial de módulos QML com CMake](https://doc.qt.io/qt-6.8/qtqml-modules-cmake-integration.html).

## Verificação visual

O executável aceita `--smoke` para percorrer todas as rotas, renderizar capturas em `build/screenshots` e encerrar. Defina `QT_QPA_PLATFORM=offscreen` e `QT_QUICK_BACKEND=software` para executar sem janela. O modo de captura também visita início, perfil e chat no tema escuro. As capturas são artefatos de validação, não telas HTML alternativas.

Use `pixi run smoke` para executar com plugins/fontes configurados ou `pixi run smoke-compact` para 360 × 800 e texto em 130%. Veja [a validação](docs/VALIDATION.md) e [a prévia visual](docs/preview.png).
