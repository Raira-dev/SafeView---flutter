// Popula o banco com ocorrências de exemplo (para a demonstração). Uso: npm run seed
const { MongoClient } = require('mongodb');
const { encaminhar } = require('./validacao');
const url = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017';

const base = [
  ['assalto', 'alta', 'Centro', 'Cruzamento Central', 'CAM 02', 'Assalto a loja de conveniência com suspeito armado.'],
  ['saude', 'alta', 'Zona Sul', 'Praça das Flores', 'CAM 04', 'Pessoa caída e desacordada próximo ao banco da praça.'],
  ['acidente', 'media', 'Zona Norte', 'Av. Principal, 1200', 'CAM 07', 'Colisão entre dois carros, sem vítimas graves.'],
  ['assalto', 'media', 'Zona Leste', 'Terminal de ônibus', 'CAM 11', 'Furto de celular na plataforma de embarque.'],
  ['saude', 'media', 'Centro', 'Estação Central', '', 'Idoso com mal-estar na saída da estação.'],
  ['acidente', 'alta', 'Zona Oeste', 'Rua das Acácias', 'CAM 09', 'Atropelamento de ciclista em faixa de pedestres.'],
  ['assalto', 'baixa', 'Zona Sul', 'Estacionamento do mercado', 'CAM 03', 'Tentativa de arrombamento de veículo.'],
  ['acidente', 'baixa', 'Centro', 'Rua Direita', '', 'Batida leve entre moto e carro, sem feridos.'],
  ['saude', 'alta', 'Zona Leste', 'Hospital Municipal (entrada)', 'CAM 12', 'Pessoa ferida após queda de escada rolante.'],
  ['assalto', 'alta', 'Centro', 'Praça da Sé', 'CAM 01', 'Roubo a pedestre com ameaça.']
];

(async () => {
  const client = new MongoClient(url);
  await client.connect();
  const col = client.db('safeview').collection('ocorrencias');
  if ((await col.countDocuments()) > 0 && !process.argv.includes('--force')) {
    console.log('A coleção já tem registros. Use "npm run seed -- --force" para inserir mesmo assim.');
  } else {
    const agora = Date.now();
    await col.insertMany(base.map(([tipo, prioridade, regiao, local, camera, descricao], i) => ({
      tipo, prioridade, regiao, local, camera, descricao, encaminhamento: encaminhar(tipo),
      status: 'Registrada', criadoEm: new Date(agora - i * 3 * 3600 * 1000)
    })));
    console.log(base.length + ' ocorrências de exemplo inseridas.');
  }
  await client.close();
})().catch((e) => { console.error(e.message); process.exit(1); });
