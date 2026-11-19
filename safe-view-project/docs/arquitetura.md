# Arquitetura

UI (screens/widgets) → Provider (AppState) → DataService (API simulada) + SharedPreferences (cache/persistência). Modelos de domínio independentes de widgets. Rotas nomeadas para fluxos e rotas de detalhe com argumentos tipados. Regras de encaminhamento no modelo de domínio; regras de alerta na camada de estado, separadas da apresentação.
