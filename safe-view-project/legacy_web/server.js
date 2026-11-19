const express = require('express');
const path = require('path');
const fs = require('fs');
const { MongoClient } = require('mongodb');
const { TIPOS, PRIORIDADES, REGIOES, validar, encaminhar } = require('./validacao');

const app = express();
const port = process.env.PORT || 3000;

// Configuração do MongoDB
const url = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017';
const client = new MongoClient(url, { serverSelectionTimeoutMS: 5000 });
let ocorrencias; // coleção "ocorrencias" do banco "safeview"

// Middlewares: leitura do formulário e arquivos estáticos (css, js, imagens)
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// ---------- Auxiliares de página ----------
const cache = {};
const tpl = (nome) => (cache[nome] ||= fs.readFileSync(path.join(__dirname, 'templates', nome + '.html'), 'utf8'));
const preencher = (t, vars) => t.replace(/{{(\w+)}}/g, (_, k) => (k in vars ? vars[k] : ''));
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const dataBR = (d) => new Date(d).toLocaleString('pt-BR', { dateStyle: 'short', timeStyle: 'short', timeZone: 'America/Sao_Paulo' });
const rota = (fn) => (req, res, next) => fn(req, res, next).catch(next);

function pagina(res, status, nome, titulo, ativo, vars = {}) {
  const conteudo = preencher(tpl(nome), vars);
  const marcas = {};
  ['inicio', 'ocorrencias', 'indicadores', 'registrar'].forEach((a) => (marcas['a_' + a] = a === ativo ? 'on' : ''));
  res.status(status).send(preencher(tpl('layout'), { titulo, conteudo, ...marcas }));
}

const alerta = (tipo, msg) => `<div class="alerta ${tipo}" role="alert">${esc(msg)}<button type="button" class="fechar" aria-label="Fechar">×</button></div>`;
const opcoes = (lista, sel, vazio) => {
  const itens = Array.isArray(lista) ? lista.map((r) => [r, r]) : Object.entries(lista);
  return `<option value="">${vazio}</option>` + itens.map(([v, r]) => `<option value="${esc(v)}"${v === sel ? ' selected' : ''}>${esc(r)}</option>`).join('');
};

// ---------- Rotas GET ----------
app.get('/', (req, res) => pagina(res, 200, 'index', 'SafeView — Monitoramento que protege e ajuda vidas', 'inicio'));

app.get('/registrar', (req, res) => pagina(res, 200, 'registrar', 'Registrar ocorrência — SafeView', 'registrar', formVars({}, {})));

function formVars(dados, erros, msg = '') {
  const e = (c) => (erros[c] ? `<small class="erro">${esc(erros[c])}</small>` : '');
  return {
    alerta: msg, v_local: esc(dados.local), v_descricao: esc(dados.descricao), v_camera: esc(dados.camera),
    opts_tipo: opcoes(TIPOS, dados.tipo, 'Selecione…'), opts_prioridade: opcoes(PRIORIDADES, dados.prioridade, 'Selecione…'),
    opts_regiao: opcoes(REGIOES, dados.regiao, 'Selecione…'),
    e_tipo: e('tipo'), e_prioridade: e('prioridade'), e_regiao: e('regiao'), e_local: e('local'), e_descricao: e('descricao'), e_camera: e('camera')
  };
}

// Aceita somente valores conhecidos nos filtros (evita injeção de operadores do MongoDB via query string)
function filtroDaUrl(q) {
  const f = {};
  if (typeof q.tipo === 'string' && q.tipo in TIPOS) f.tipo = q.tipo;
  if (typeof q.prioridade === 'string' && q.prioridade in PRIORIDADES) f.prioridade = q.prioridade;
  if (typeof q.regiao === 'string' && REGIOES.includes(q.regiao)) f.regiao = q.regiao;
  return f;
}

app.get('/ocorrencias', rota(async (req, res) => {
  const filtro = filtroDaUrl(req.query);
  const [lista, filtrados, total] = await Promise.all([
    ocorrencias.find(filtro).sort({ criadoEm: -1 }).limit(200).toArray(),
    ocorrencias.countDocuments(filtro),
    ocorrencias.countDocuments()
  ]);
  const linhas = lista.map((o) => `<tr><td>${dataBR(o.criadoEm)}</td><td><span class="tag t-${esc(o.tipo)}">${esc(TIPOS[o.tipo])}</span></td>
    <td><span class="pr p-${esc(o.prioridade)}">${esc(PRIORIDADES[o.prioridade])}</span></td><td>${esc(o.regiao)}</td>
    <td><strong>${esc(o.local)}</strong>${o.camera ? ` · ${esc(o.camera)}` : ''}<small>${esc(o.descricao)}</small></td><td>${esc(o.encaminhamento)}</td></tr>`).join('');
  pagina(res, 200, 'ocorrencias', 'Ocorrências — SafeView', 'ocorrencias', {
    alerta: req.query.ok ? alerta('ok', 'Ocorrência registrada com sucesso!') : '',
    f_tipo: opcoes(TIPOS, filtro.tipo, 'Todos os tipos'), f_prioridade: opcoes(PRIORIDADES, filtro.prioridade, 'Todas as prioridades'),
    f_regiao: opcoes(REGIOES, filtro.regiao, 'Todas as regiões'),
    resumo: `Exibindo <strong>${filtrados}</strong> de <strong>${total}</strong> registros`,
    tabela: lista.length ? `<div class="rolagem"><table><thead><tr><th>Data</th><th>Tipo</th><th>Prioridade</th><th>Região</th><th>Local e descrição</th><th>Encaminhamento</th></tr></thead><tbody>${linhas}</tbody></table></div>`
      : '<p class="vazio">Nenhuma ocorrência encontrada. <a href="/registrar">Registre a primeira</a>.</p>'
  });
}));

// Indicadores: total de registros + resumo por tipo, prioridade e região
async function calcularIndicadores() {
  const agrupar = async (campo) => {
    const r = await ocorrencias.aggregate([{ $group: { _id: '$' + campo, total: { $sum: 1 } } }]).toArray();
    return Object.fromEntries(r.map((x) => [x._id, x.total]));
  };
  const [total, tipo, prioridade, regiao] = await Promise.all([ocorrencias.countDocuments(), agrupar('tipo'), agrupar('prioridade'), agrupar('regiao')]);
  const maior = (m) => Object.entries(m).sort((a, b) => b[1] - a[1])[0];
  return { total, tipo, prioridade, regiao, pctAlta: total ? Math.round(((prioridade.alta || 0) / total) * 100) : 0, tipoTop: maior(tipo), regiaoTop: maior(regiao) };
}

app.get('/indicadores', rota(async (req, res) => {
  const i = await calcularIndicadores();
  const barras = (titulo, mapa, chaves, rotulo) => `<div class="card"><h3>${titulo}</h3>` + chaves.map((k) => {
    const n = mapa[k] || 0, p = i.total ? Math.round((n / i.total) * 100) : 0;
    return `<div class="linha-barra"><div><span>${esc(rotulo(k))}</span><span>${n} (${p}%)</span></div><div class="bar"><i style="width:${p}%"></i></div></div>`;
  }).join('') + '</div>';
  const kpi = (r, v) => `<div class="kpi"><span>${r}</span><strong>${v}</strong></div>`;
  pagina(res, 200, 'indicadores', 'Indicadores — SafeView', 'indicadores', {
    kpis: kpi('Total de registros', i.total) + kpi('Prioridade alta', i.pctAlta + '%') +
      kpi('Tipo mais frequente', i.tipoTop ? TIPOS[i.tipoTop[0]] : '—') + kpi('Região com mais registros', i.regiaoTop ? i.regiaoTop[0] : '—'),
    barras: barras('Por tipo de ocorrência', i.tipo, Object.keys(TIPOS), (k) => TIPOS[k]) +
      barras('Por prioridade', i.prioridade, Object.keys(PRIORIDADES), (k) => PRIORIDADES[k]) +
      barras('Por região', i.regiao, REGIOES, (k) => k)
  });
}));

// Rotas de dados em JSON (úteis para demonstração e testes)
app.get('/api/ocorrencias', rota(async (req, res) => {
  res.json(await ocorrencias.find(filtroDaUrl(req.query)).sort({ criadoEm: -1 }).limit(200).toArray());
}));
app.get('/api/indicadores', rota(async (req, res) => res.json(await calcularIndicadores())));

// ---------- Rota POST: recebe, valida e salva ----------
app.post('/ocorrencias/save', rota(async (req, res) => {
  const { dados, erros, valido } = validar(req.body);
  if (!valido) {
    return pagina(res, 400, 'registrar', 'Registrar ocorrência — SafeView', 'registrar',
      formVars(dados, erros, alerta('erro', 'Não foi possível salvar. Corrija os campos destacados.')));
  }
  await ocorrencias.insertOne({ ...dados, encaminhamento: encaminhar(dados.tipo), status: 'Registrada', criadoEm: new Date() });
  res.redirect(303, '/ocorrencias?ok=1');
}));

// ---------- 404 e erros ----------
app.use((req, res) => pagina(res, 404, '404', 'Página não encontrada — SafeView', ''));
app.use((err, req, res, next) => {
  console.error(err);
  pagina(res, 500, '500', 'Erro no servidor — SafeView', '');
});

// ---------- Inicialização ----------
async function iniciar() {
  await client.connect();
  ocorrencias = client.db('safeview').collection('ocorrencias');
  app.listen(port, () => console.log(`SafeView rodando em http://localhost:${port}`));
}
iniciar().catch((e) => {
  console.error('Não foi possível conectar ao MongoDB em ' + url + '\n' + e.message);
  process.exit(1);
});
