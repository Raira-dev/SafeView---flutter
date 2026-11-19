# SafeView — Global Solution 2026.2 (Application Development)

Aplicação web para **registrar e acompanhar ocorrências** (assaltos, acidentes e emergências de saúde) detectadas por câmeras ou relatadas por pessoas, encaminhando cada caso à unidade certa e gerando indicadores.

## Problema, público-alvo, objetivo e ODS
- **Problema:** assaltos, acidentes e emergências de saúde em espaços públicos nem sempre são percebidos e comunicados a tempo; a demora no acionamento da Polícia e do SAMU piora o desfecho e falta visibilidade sobre onde e quanto essas ocorrências acontecem.
- **Público-alvo:** cidadãos e comunidades, equipes de monitoramento (empresas e prefeituras) e unidades de resposta (Polícia e SAMU).
- **Objetivo:** registrar ocorrências, encaminhá-las por regra e gerar indicadores que apoiem decisões mais rápidas.
- **ODS:** **ODS 11** (Cidades e Comunidades Sustentáveis, principal), **ODS 3** (Saúde e Bem-Estar) e **ODS 16** (Paz, Justiça e Instituições Eficazes).

## Como executar
Pré-requisitos: Node.js 18+ e MongoDB rodando em `mongodb://127.0.0.1:27017` (ou outra URL na variável `MONGODB_URI`, por exemplo MongoDB Atlas).

```bash
npm install
npm start          # http://localhost:3000
npm run seed       # opcional: insere 10 ocorrências de exemplo
```
Banco: `safeview` · Coleção: `ocorrencias` (criados automaticamente). Porta alterável com `PORT`.

## Rotas
| Método | Rota | Função |
|---|---|---|
| GET | `/` | Página inicial com introdução (problema, público, objetivo, ODS) |
| GET | `/registrar` | Formulário de registro |
| POST | `/ocorrencias/save` | Recebe, valida e salva no MongoDB (erro → volta ao formulário com mensagens; sucesso → redireciona com confirmação) |
| GET | `/ocorrencias` | Lista os registros, com filtros por tipo, prioridade e região |
| GET | `/indicadores` | Indicadores calculados com os dados salvos |
| GET | `/api/ocorrencias`, `/api/indicadores` | Os mesmos dados em JSON |
| qualquer outra | — | Página 404 |

## Registro (campos)
`tipo`, `prioridade`, `regiao`, `local`, `descricao`, `camera` (opcional) e, gerados pelo servidor, `encaminhamento`, `status` e `criadoEm`.
Validações: tipo, prioridade e região precisam estar nas listas permitidas; local de 3 a 100 caracteres; descrição de 10 a 500; câmera no formato `CAM 02`.

## Indicadores e regra de classificação
- **Total de registros:** quantidade de documentos na coleção.
- **Resumo por categoria e prioridade:** agrupamento (`$group`) por tipo, por prioridade e por região, com quantidade e percentual sobre o total.
- **Prioridade alta (%)**, **tipo mais frequente** e **região com mais registros** completam o painel.
- **Regra de encaminhamento:** assalto → Polícia; acidente → SAMU + Polícia; emergência de saúde → SAMU / Ambulância.

## Organização dos arquivos
```
server.js        servidor Express, rotas GET/POST, conexão MongoDB, 404/500
validacao.js     listas permitidas, validação dos campos e regra de encaminhamento
seed.js          dados de exemplo
templates/       páginas HTML (layout, home, formulário, lista, indicadores, 404, 500)
public/          css, js e imagens
docs/roteiro-pitch.md   roteiro do vídeo pitch
```

## Vídeo pitch
Link: _(colar aqui o link do YouTube)_ — roteiro em `docs/roteiro-pitch.md`.

## Observação
O protótipo visual completo do SafeView (login, perfis de Polícia/SAMU/Cidadão, painel de câmeras) fica como evolução futura; login não faz parte do escopo desta entrega.
