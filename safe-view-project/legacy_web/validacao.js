// Regras de negócio: listas permitidas, validação dos campos e classificação por regra.
const TIPOS = { assalto: 'Assalto', acidente: 'Acidente', saude: 'Emergência de saúde' };
const PRIORIDADES = { baixa: 'Baixa', media: 'Média', alta: 'Alta' };
const REGIOES = ['Centro', 'Zona Norte', 'Zona Sul', 'Zona Leste', 'Zona Oeste'];

// Regra de classificação: define qual unidade deve atender a ocorrência.
function encaminhar(tipo) {
  if (tipo === 'assalto') return 'Polícia';
  if (tipo === 'acidente') return 'SAMU + Polícia';
  return 'SAMU / Ambulância';
}

// Validação básica: retorna os dados já limpos e um objeto com as mensagens de erro.
function validar(body) {
  const txt = (v) => (typeof v === 'string' ? v.trim() : '');
  const dados = {
    tipo: txt(body.tipo),
    prioridade: txt(body.prioridade),
    regiao: txt(body.regiao),
    local: txt(body.local),
    descricao: txt(body.descricao),
    camera: txt(body.camera).toUpperCase()
  };
  const erros = {};

  if (!(dados.tipo in TIPOS)) erros.tipo = 'Escolha o tipo da ocorrência.';
  if (!(dados.prioridade in PRIORIDADES)) erros.prioridade = 'Escolha a prioridade.';
  if (!REGIOES.includes(dados.regiao)) erros.regiao = 'Escolha a região.';
  if (dados.local.length < 3 || dados.local.length > 100)
    erros.local = 'Informe o local com 3 a 100 caracteres.';
  if (dados.descricao.length < 10 || dados.descricao.length > 500)
    erros.descricao = 'A descrição deve ter de 10 a 500 caracteres.';
  if (dados.camera && !/^CAM ?\d{1,3}$/.test(dados.camera))
    erros.camera = 'Use o formato CAM 02 (opcional).';

  return { dados, erros, valido: Object.keys(erros).length === 0 };
}

module.exports = { TIPOS, PRIORIDADES, REGIOES, validar, encaminhar };
