# Estuda.AI

Aplicação web single-file para estudos de **CACD 2027** e **Direito** (Faculdade Nova Roma), com geração de conteúdo via IA, simulados, redação dissertativa, gerenciamento de matérias por período/unidade e sincronização via Supabase.

Hospedada em **GitHub Pages** — sem backend próprio, sem build, sem dependências de npm.

---

## Funcionalidades

### Historinhas
Gera narrativas curtas para memorização de conteúdo jurídico e diplomático. O modelo recebe a matéria, a unidade (N1/N2/N3) e os tópicos cadastrados como contexto, produzindo uma história com personagens e situações que cristaliza os conceitos no final em bullet points.

### Simulados
Questões de múltipla escolha no padrão CACD com gabarito comentado. Suporta três tipos de armadilha identificados nas edições anteriores do concurso:

| Armadilha | Descrição |
|-----------|-----------|
| Cauda venenosa | Alternativa quase correta com detalhe errado no final |
| Absolutismo | Uso de "sempre", "nunca", "apenas", "exclusivamente" |
| Inversão causa-efeito | Distrator que inverte a relação causal correta |

### Redação CACD
Geração de tema dissertativo com instruções e critérios de avaliação. Aceita a redação do usuário e devolve correção com notas em cinco critérios: argumentação, conhecimento de política internacional, estrutura dissertativa, coesão e perfil diplomático.

### Material de Estudo (PDF / Texto)
Upload de PDF ou texto colado manualmente. A partir do conteúdo inserido, gera à escolha:
- **Historinha** — resumo narrativo para memorização
- **Flashcards** — deck interativo de perguntas e respostas, cada card abre e fecha com clique
- **Questões** — múltipla escolha com gabarito revelado para revisão imediata

O conteúdo gerado pode ser salvo e consultado na aba "Materiais salvos".

### Matérias & Períodos (CRUD)
Gerenciamento completo de matérias para CACD e Direito em listas separadas, com três abas:

**CACD** — matérias do concurso diplomático, sem períodos.

**Direito** — matérias da graduação, filtradas pelo período ativo. Cada matéria pode ser vinculada a um período específico do curso.

**Períodos** — CRUD dos períodos de graduação (1º ao 10º). Um período pode ser marcado como ativo; ao ativá-lo, apenas as matérias vinculadas a ele aparecem nos selects de Historinhas, Simulados e Material de Estudo. Um seletor rápido na sidebar permite trocar o período ativo sem entrar no CRUD.

Cada matéria possui tópicos organizados por unidade de avaliação:

| Unidade | Escopo na prova |
|---------|----------------|
| N1 | Conteúdo exclusivo da primeira avaliação |
| N2 | Conteúdo próprio + pode revisar N1 |
| N3 | Conteúdo novo + pode cobrar tudo do semestre |

Os tópicos cadastrados são injetados automaticamente no prompt da IA — sem necessidade de digitar contexto manualmente a cada geração.

### Autenticação e Sincronização (Supabase)
Login com email e senha via Supabase Auth. Todos os dados (matérias, períodos, historinhas salvas, materiais, stats, histórico e preferências) são sincronizados em tempo real com o banco PostgreSQL do Supabase.

Estratégia offline/online:
- **Online + autenticado** → lê do Supabase ao abrir, grava a cada ação
- **Offline** → opera via localStorage sem interrupção
- **Reconexão** → sincroniza automaticamente
- **Sem login** → modo offline completo via localStorage

O badge de status na topbar indica o estado atual em tempo real.

### Temas de interface
Três temas com preferência salva entre sessões:
- **Escuro** — padrão, fundo quase preto
- **Cinza** — bege-acinzentado, contraste reduzido para leitura longa
- **Claro** — off-white com texto escuro

### Progresso
Contador de historinhas geradas, questões respondidas, taxa de acerto e redações. Histórico das últimas 30 atividades com data e tipo.

---

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Frontend | HTML + Vanilla JS + CSS (sem framework) |
| IA | Claude Haiku 4.5 via Anthropic API |
| Banco de dados | Supabase (PostgreSQL) + localStorage como fallback |
| Auth | Supabase Auth (email/senha) |
| Hospedagem | GitHub Pages |
| Dependências externas | Supabase JS SDK v2 · Google Fonts |

Arquivo principal: `index.html` — sem `package.json`, sem build, sem servidor próprio.

---

## Estrutura do repositório

```
estuda-ai/
├── index.html                        # App completo (single-file)
├── README.md                         # Este arquivo
├── supabase-schema.sql               # Schema inicial do banco
├── supabase-migration-periodos.sql   # Migration: tabela periodos + periodo_id
└── SUPABASE-SETUP.md                 # Guia passo a passo de configuração
```

---

## Configuração do Supabase

### 1. Criar projeto
Acesse [supabase.com](https://supabase.com) → New project → região São Paulo.

### 2. Executar o schema
No SQL Editor, execute em ordem:
1. `supabase-schema.sql` — cria todas as tabelas com RLS
2. `supabase-migration-periodos.sql` — adiciona períodos e vínculo com matérias

### 3. Obter credenciais
Project Settings → API:
- **Project URL** → `https://xxxxxxxxxxx.supabase.co`
- **Anon public key** → `eyJ...`

### 4. Configurar no app
⚙ Configurar API → preencher Supabase URL, Anon Key e chave Anthropic.

O guia completo está em `SUPABASE-SETUP.md`.

---

## Configuração da API Anthropic

1. Acesse [console.anthropic.com](https://console.anthropic.com) → API Keys → criar nova chave
2. No app: ⚙ Configurar API → campo "Chave Anthropic" → salvar

**Modelo:** `claude-haiku-4-5` — mais econômico da família Claude.
**Custo estimado:** ~$0.001 por historinha. 100 historinhas + 50 simulados/mês ≈ R$0,80.

---

## Publicação no GitHub Pages

```bash
# Renomear se necessário
mv estuda-ai.html index.html

# Subir
git add .
git commit -m "feat: Estuda.AI"
git push origin main

# Ativar Pages
# Repositório → Settings → Pages → Branch: main → Save
```

URL pública: `https://felipealima1984.github.io/estuda-ai`

Lembre de adicionar essa URL em **Supabase → Authentication → URL Configuration → Redirect URLs**.

---

## Matérias pré-carregadas

### CACD
- Direito Internacional Público
- Direito Internacional Privado
- Economia
- História do Brasil
- Política Internacional

### Direito (Nova Roma — 4º Período)
- Direito Penal — Crimes em Espécie
- Direito Civil — Contratos em Espécie
- MARC — Mediação e Arbitragem

Novas matérias, períodos e tópicos são gerenciados diretamente no app, sem editar código.

---

## Banco de dados — tabelas

| Tabela | Conteúdo |
|--------|----------|
| `materias` | Matérias CACD e Direito com tópicos N1/N2/N3 e vínculo de período |
| `periodos` | Períodos de graduação (1º ao 10º) com flag de ativo |
| `historinhas` | Historinhas salvas manualmente |
| `materiais_salvos` | Conteúdo gerado de PDF/texto (historinha, flashcards, questões) |
| `stats` | Contadores de uso por usuário |
| `historico` | Últimas 30 atividades por usuário |
| `preferencias` | Tema visual, chave Anthropic e período ativo |

Todas as tabelas têm **Row Level Security** ativo — cada usuário acessa apenas seus próprios dados.

---

## localStorage (modo offline / fallback)

| Chave | Conteúdo |
|-------|----------|
| `estuda_api_key` | Chave Anthropic |
| `estuda_materias` | Matérias e tópicos |
| `estuda_periodos` | Períodos cadastrados |
| `estuda_periodo_ativo` | ID do período ativo |
| `estuda_stats` | Contadores |
| `estuda_historico` | Histórico de atividades |
| `estuda_historinhas` | Até 50 historinhas salvas |
| `estuda_materiais_salvos` | Materiais gerados de PDF/texto |
| `estuda_theme` | Tema visual |
| `sb_url` / `sb_key` | Credenciais Supabase |

Para limpar tudo localmente: `localStorage.clear()` no console do navegador.

---

## Histórico de versões

### v1.3 — Períodos de graduação
- CRUD de períodos (1º ao 10º) vinculados às matérias de Direito
- Seletor rápido de período ativo na sidebar
- Filtro automático de matérias por período em Historinhas, Simulados e Material de Estudo
- Migration SQL `supabase-migration-periodos.sql`
- Sync de períodos e `periodo_id` nas matérias com o Supabase

### v1.2 — Supabase Auth + Sync
- Login com email e senha via Supabase Auth
- Sincronização em tempo real de matérias, stats, histórico, historinhas, materiais e preferências
- Estratégia offline/online com localStorage como fallback
- Badge de status de sincronização na topbar
- Schema SQL completo com RLS por usuário

### v1.1 — Material de Estudo + Períodos base
- Upload de PDF (extração de texto) e entrada de texto manual
- Geração de historinha, flashcards e questões a partir do material
- Materiais salvos com visualização e exclusão
- CRUD de matérias com períodos N1/N2/N3 por matéria
- Seleção de período filtrando conteúdo gerado pela IA

### v1.0 — Versão inicial
- Historinhas por matéria e unidade (CACD e Direito)
- Simulados com armadilhas CACD
- Redação dissertativa com correção
- CRUD de matérias com tópicos por N1/N2/N3
- Três temas de interface (escuro, cinza, claro)
- Persistência via localStorage

---

## Roadmap

- [ ] Deck de repetição espaçada (flashcards com algoritmo SM-2)
- [ ] Histórico de notas das redações com gráfico de evolução
- [ ] Exportação de historinhas e flashcards para PDF
- [ ] Modo offline completo com Service Worker
- [ ] Estatísticas por matéria e por período

---

## Licença

Projeto pessoal. Sem licença open source definida.
