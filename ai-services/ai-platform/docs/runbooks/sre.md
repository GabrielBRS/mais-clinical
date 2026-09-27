# SRE e capacidade inicial

Estado: DOCUMENTED ONLY para SLOs de produção. Não há meta empresarial definida.
Experimento proposto: disponibilidade de tool = chamadas válidas concluídas /
chamadas válidas tentadas; latência por histograma da tool. HTTP 200 não basta
porque MCP pode retornar `isError`. Separar negação de autorização e falha interna.

Uma meta experimental só deve ser fixada após baseline e identificação de quais
erros entram no denominador. Error budget deriva da meta e janela acordadas.
Dashboard atual permite observar taxas/duração, mas não comprova SLO.

Incidente: captura de sintoma, janela, contexto, hipóteses e evidências. Não
capturar dados clínicos ou tokens. Correlacionar request/agent/tool spans quando
OTLP ativo; ausência de backend durável limita investigação retroativa.

Dados recuperáveis do Git: código, chart, corpus público e configuração sem
secrets. Precisam de backup/gestão próprios: secrets e futuros bancos/checkpoints.
Métricas/traces locais são efêmeros. RPO/RTO só podem ser declarados após teste
de restore do componente correspondente.

Métricas de entrega futuras: frequência por deploy bem-sucedido; lead time do
commit até deploy; taxa de falha por mudança causadora; tempo de restauração
por incidente. Registrar origem e janela; não usar volume de commits como
substituto de impacto ou qualidade. CI local não mede DORA de produção.
