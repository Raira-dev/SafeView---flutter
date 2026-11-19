# SafeView — Observe. Alerta. Protege.

**Painel de inteligência territorial em Flutter para registrar, acompanhar e analisar ocorrências de segurança, trânsito e emergências de saúde.**

> Global Solution 2026.2 · FIAP · CitizenTech · Territory Predictive Insights

## 1. Problema e público

Assaltos, acidentes e emergências de saúde em espaços públicos nem sempre são percebidos e comunicados a tempo. A demora no acionamento dos serviços de resposta pode agravar situações, enquanto a falta de visibilidade territorial dificulta a priorização de recursos.

O SafeView foi criado para cidadãos e comunidades, equipes de monitoramento e unidades públicas de resposta, como Polícia e SAMU. O aplicativo registra ocorrências, sugere encaminhamentos por regras explícitas e apresenta indicadores e sinais de atenção para apoiar decisões humanas. Busca contribuir com ODS 11 (Cidades e Comunidades Sustentáveis), ODS 3 (Saúde e Bem-Estar) e ODS 16 (Paz, Justiça e Instituições Eficazes).

## 2. Integrantes

| Nome completo | RM |
|---|---|
| [Anny Elly] | [RM565055] |
| [Larissa Machado] | [RM564168] |
| [Raira T. Costa] | [RMr64850] |

## 3. Demonstração visual

As capturas reais devem ser feitas em emulador/dispositivo após executar o app e salvas em `assets/screenshots/`. Não foram fabricadas capturas: o ambiente de preparação não possui Flutter instalado para executar o aplicativo.

| Tela | Arquivo sugerido | Legenda |
|---|---|---|
| Início | `home.png` | Visão geral, KPIs e impacto social |
| Painéis | `dashboards.png` | Três dashboards territoriais |
| Ocorrências | `occurrences.png` | Lista e filtros |
| Registro | `register.png` | Formulário validado |
| Alertas | `alerts.png` | Sinais, confiança e evidências |
| Detalhe do alerta | `alert-detail.png` | Justificativa e limitações |
| Preferências | `settings.png` | Privacidade e acessibilidade |

## 4. Funcionalidades

- [x] Aplicativo Flutter com navegação nomeada e passagem de parâmetros.
- [x] Mais de cinco telas: início, painéis, ocorrências, detalhes, registro, alertas e preferências.
- [x] Três dashboards: tipo, prioridade e região, com contagens, percentuais e barras.
- [x] Alertas gerados por regras transparentes, com evidência, confiança indicativa e limitações.
- [x] Aviso explícito de decisão final humana; não há acionamento automático.
- [x] Estado global compartilhado com Provider e estado local nos filtros/formulário.
- [x] Estados de carregamento, erro/offline e lista vazia.
- [x] Serviço de dados simulado com latência de API.
- [x] Persistência local de ocorrências, consentimento e preferências via SharedPreferences.
- [x] Uso offline com dados em cache/local.
- [x] Formulário com validação e mensagens de erro.
- [x] Indicador social: registros com encaminhamento sugerido.
- [x] Preferências de tema, texto ampliado e alto contraste.
- [x] Consentimento explícito e minimização de dados pessoais.
- [x] Testes unitários para regras de encaminhamento e rótulos.

## 5. Dados e alertas

### Fonte

A versão Flutter inclui um serviço simulado (`lib/services/data_service.dart`) que retorna dez registros sintéticos inspirados nos cenários de demonstração do SafeView original. O app identifica essa fonte como sintética; não são dados oficiais nem detecções reais de câmeras. Novos registros são armazenados localmente no dispositivo.

### Regras e métricas

O encaminhamento reproduz as regras do projeto original:

- Assalto → Polícia.
- Acidente → SAMU + Polícia.
- Emergência de saúde → SAMU / Ambulância.

Um sinal de atenção é gerado para uma região com pelo menos dois registros ou ao menos um registro de prioridade alta. A confiança apresentada é uma pontuação heurística ilustrativa, calculada a partir da participação daquela região na amostra, limitada a 55%–90%. Não é probabilidade calibrada, modelo de machine learning ou previsão validada.

Os painéis apresentam total de registros, distribuição por tipo, prioridade e região, percentual de prioridade alta e região com maior contagem.

### Limitações e vieses

A amostra é pequena, sintética e não representativa. Não há denominador populacional, georreferenciamento preciso, ajuste por sazonalidade, horário, subnotificação ou exposição a câmeras. Áreas com maior acesso a monitoramento/canais de denúncia podem aparentar maior incidência. Correlação/contagem não implica causalidade. Previsões não são confiáveis quando a amostra é pequena, desatualizada, enviesada ou não comparável. Os alertas apenas apoiam análise; a decisão final é humana.

## 6. Privacidade e inclusão

O formulário não solicita nome, CPF, telefone ou contato. A persistência é local no dispositivo; o conjunto inicial é sintético. A tela inicial solicita consentimento antes de usar os dados demonstrativos e a tela de preferências permite rever o consentimento. Foram incluídos rótulos semânticos padrão de widgets Flutter, controles com tooltips/labels, suporte a escala de texto e opções de tema. Antes da entrega, testar leitores de tela e contraste em dispositivos reais.

## 7. Tecnologias e decisões técnicas

- **Flutter/Dart:** aplicativo multiplataforma com uma base de código.
- **Provider:** estado global simples e reativo, compartilhado entre telas.
- **SharedPreferences:** persistência leve de registros e preferências, adequada ao protótipo offline.
- **DataService:** abstração de fonte simulada; permite substituir por API REST real sem acoplar telas.
- **Material 3:** componentes consistentes, responsivos e acessíveis.
- **Navigator com rotas nomeadas:** fluxo explícito e passagem de objetos para telas de detalhe.

### Estrutura

```text
lib/
  main.dart
  models/occurrence.dart
  providers/app_state.dart
  services/data_service.dart
  screens/
    home_screen.dart
    dashboard_screen.dart
    occurrences_screen.dart
    register_screen.dart
    alerts_screen.dart
    settings_screen.dart
  widgets/common.dart
assets/
  img/                 # identidade visual original
  screenshots/         # capturas reais a adicionar
docs/
  roteiro-pitch.md
legacy_web/            # projeto web original preservado
test/
```

## 8. Como executar

Pré-requisitos: Flutter SDK estável, Android Studio/VS Code e emulador ou dispositivo.

```bash
# Gere os diretórios nativos de plataforma (Android/iOS/Web) uma única vez:
flutter create . --platforms=android,ios,web
flutter doctor
flutter pub get
flutter analyze
flutter test
flutter run
```

Para gerar APK:

```bash
flutter build apk --release
```

O APK estará em `build/app/outputs/flutter-apk/app-release.apk`.

Não há chave de API na versão demonstrativa. Para futura integração REST, configure a URL por ambiente e não versione credenciais. O serviço simulado funciona sem configuração externa.


## 9. Licença

Projeto acadêmico — FIAP, Global Solution 2026.2. Uso educacional.