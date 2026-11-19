# Roteiro do vídeo pitch (2 a 3 minutos)

**0:00 – 0:30 · Contextualização** (mostrar a página inicial)
"Olá, eu sou [nome] e este é o SafeView. Assaltos, acidentes e emergências de saúde em espaços públicos nem sempre são percebidos a tempo, e quando a Polícia ou o SAMU demoram a ser acionados o desfecho piora. Nosso público são cidadãos, equipes de monitoramento e as unidades de resposta. O objetivo é registrar as ocorrências, encaminhar cada uma à unidade certa e mostrar onde e quanto elas acontecem. A solução se relaciona com o ODS 11, cidades e comunidades sustentáveis, e também com os ODS 3 e 16."

**0:30 – 1:30 · Demonstração** (navegar pelo protótipo)
1. Em **Registrar**, enviar o formulário vazio para mostrar as mensagens de erro da validação.
2. Preencher corretamente (ex.: Assalto, prioridade alta, Centro, "Cruzamento Central", CAM 02) e enviar; mostrar a mensagem de sucesso.
3. Em **Ocorrências**, mostrar a lista, o encaminhamento automático (Polícia) e usar os filtros.
4. Em **Indicadores**, mostrar o total, o resumo por tipo, prioridade e região e o percentual de prioridade alta.
5. Digitar uma rota inexistente (ex.: /teste) para mostrar a página 404.

**1:30 – 2:30 · Código**
- `server.js`: Express com `urlencoded` e `static`; conexão com `MongoClient`; rota **GET /registrar** (formulário), **POST /ocorrencias/save** (valida, salva com `insertOne` e redireciona) e **GET /ocorrencias** (lista com `find`).
- `validacao.js`: valida os campos e define a regra de encaminhamento por tipo.
- Indicadores: `countDocuments` para o total e `aggregate` com `$group` para o resumo por categoria.
- Tratamento de erros: middleware final devolve a página 404.

**2:30 – 3:00 · Fechamento**
"O SafeView transforma registros em informação útil para agir mais rápido. Como próximos passos: perfis de acesso (Polícia, SAMU e cidadão) e integração com as câmeras. Obrigado!"
