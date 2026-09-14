# SIP — Estado Atual do Repositório

**Data de auditoria:** 2026-09-14
**Auditor:** orchestrator (Behavior OS)
**Versão:** 2.0.0
**Task:** TASK-000 — Auditoria e preparação do repositório

---

## 1. Ambiente do Sistema

| Componente | Versão | Status |
|------------|--------|--------|
| OS | Ubuntu 26.04.1 LTS | ✅ OK |
| Ruby | 3.4.10 (via mise) | ✅ OK |
| Rails | 8.1.3.1 | ✅ OK |
| Node.js | v24.20.0 (via nvm) | ✅ OK |
| Bun | 1.3.10 | ✅ OK |
| Git | 2.53.0 | ✅ OK |
| Docker | 29.7.2 (running) | ✅ OK |
| PostgreSQL | 17.11 (Docker container) | ✅ OK |
| pnpm | — | PENDING |

---

## 2. Estrutura do Projeto

```
/home/naldiocj/apps/sip/
├── .behavior-os/        # Behavior OS kernel (ativo)
│   ├── dna/             # 14 perfis de agentes
│   ├── evidence/        # Evidências de execução
│   ├── knowledge/       # Knowledge packs
│   ├── state/           # Estado da missão
│   └── truth/           # Truth base (versões)
├── .git/                # Repositório Git (inicializado)
├── .opencode/           # Configuração OpenCode
│   ├── agents/          # Definições de agentes
│   ├── commands/        # Comandos customizados
│   ├── plugins/         # behavior-os.ts plugin
│   ├── rules/           # Regras de governança
│   ├── skills/          # 39 skills disponíveis
│   └── tools/           # 16 custom tools bos_*
├── app/
│   ├── controllers/     # ApplicationController, concerns
│   ├── jobs/            # ApplicationJob
│   ├── mailers/         # ApplicationMailer
│   ├── models/          # 14 models criados
│   ├── views/           # layouts, pwa
│   └── helpers/         # ApplicationHelper
├── config/
│   ├── application.rb   # Module Sip
│   ├── database.yml     # PostgreSQL (3 databases)
│   ├── routes.rb        # Health check + Turbo
│   └── environments/    # dev/test/production
├── db/
│   ├── migrate/         # 14 migrations
│   ├── schema.rb        # Schema atual
│   └── seeds.rb         # Seed file
├── docs/
│   ├── audit/
│   │   └── CURRENT_STATE.md
│   └── architecture/
├── lib/
├── public/
├── spec/
│   ├── factories/       # 10 factories geradas
│   ├── models/          # 10 specs gerados
│   └── spec_helper.rb   # Configuração RSpec
├── test/                # Testes padrão Rails
├── Gemfile              # 38 gems
├── Gemfile.lock         # Lockfile atualizado
├── docker-compose.yml   # PostgreSQL em Docker
├── .env.example         # Variáveis de ambiente
└── AGENTS.md            # Regras de governança
```

---

## 3. Stack Tecnológica

### Backend
- **Ruby on Rails** 8.1.3.1
- **PostgreSQL** 17.11 (Docker)
- **Rodauth** 2.47 (autenticação)
- **Pundit** 2.3 (autorização)
- **Solid Queue** (jobs assíncronos)
- **Solid Cache** (cache)
- **Solid Cable** (WebSocket)
- **Active Storage** (arquivos)

### Frontend
- **ERB** templates
- **Turbo** (Hotwire)
- **Stimulus** (controllers)
- **Tailwind CSS** v4 (via tailwindcss-rails)
- **Propshaft** (assets)

### Qualidade & Testes
- **RSpec Rails** 7.x
- **Factory Bot** 6.x
- **Shoulda Matchers** 6.x
- **Database Cleaner** 2.x
- **RuboCop Rails Omakase**
- **Brakeman** 8.x
- **Bundler Audit** 0.9

### Geração de Documentos
- **Wicked PDF** 2.8
- **wkhtmltopdf-binary** 0.12
- **Docx** 0.13 (importação Word)
- **Caxlsx** 4.x (exportação Excel)
- **Roo** 2.10 (leitura spreadsheets)

---

## 4. Banco de Dados — Schema

### Tabelas Criadas (14)

| Tabela | Colunas | Descrição |
|--------|---------|-----------|
| `organizations` | id, name, code, parent_id, level, description, created_by, updated_by, timestamps | Hierarquia organizacional |
| `users` | id, email, username, password_digest, first_name, last_name, organization_id, status, timestamps | Utilizadores |
| `profiles` | id, name, code, description, timestamps | Perfis (ADMIN, INSTRUTOR, etc.) |
| `capabilities` | id, name, description, timestamps | Capacidades (process.read, etc.) |
| `user_assignments` | id, user_id, organization_id, profile_id, role, started_at, ended_at, timestamps | Afectações com histórico |
| `profile_capabilities` | id, profile_id, capability_id, timestamps |many-to-many |
| `process_types` | id, name, code, description, timestamps | Tipos de processo |
| `sip_processes` | id, numero, tipo_id, origem, estado, prioridade, prazo, organizacao_id, responsavel_id, criador_id, timestamps | Processos |
| `workflow_transitions` | id, process_id, from_state, to_state, action, actor_id, required_capability, scope_rule, observacao, timestamps | Histórico de workflow |
| `documents` | id, process_id, document_type_id, title, description, status, uploader_id, timestamps | Documentos |
| `diligences` | id, process_id, diligencia_type, descricao, estado, responsavel_id, data_prevista, data_real, timestamps | Diligências |
| `diligence_types` | id, name, code, description, timestamps | Tipos de diligência |
| `mandates` | id, process_id, mandate_type, emissor_id, destino, descricao, estado, data_emissao, data_prazo, timestamps | Mandados |
| `evidences` | id, process_id, evidence_type, descricao, collector_id, collected_at, timestamps | Evidências |

---

## 5. Modelos com Associações

| Modelo | Associações |
|--------|-------------|
| `Organization` | belongs_to :parent, has_many :children, has_many :users, has_many :sip_processes |
| `User` | has_secure_password, belongs_to :organization, has_many :user_assignments, has_many :organizations (through), has_many :created_sip_processes, has_many :managed_sip_processes |
| `Profile` | has_many :profile_capabilities, has_many :capabilities, has_many :user_assignments |
| `Capability` | has_many :profile_capabilities, has_many :profiles |
| `UserAssignment` | belongs_to :user, organization, profile. Scope: active? |
| `SipProcess` | belongs_to :tipo, :organizacao, :responsavel, :criador. has_many :workflow_transitions, :documents, :diligences, :mandates, :evidences |
| `Document` | belongs_to :process, :uploader. has_one_attached :file |
| `Diligence` | belongs_to :process, :responsavel, :diligencia_type. has_one_attached :result |
| `Mandate` | belongs_to :process, :emissor |
| `Evidence` | belongs_to :process, :collector. has_one_attached :file |
| `WorkflowTransition` | belongs_to :process, :actor (optional) |

---

## 6. Migrations & Schema

- **Versão do schema:** 2026_09_14_182642
- **Total de migrations:** 14
- **Database adapter:** postgresql
- **Extensões habilitadas:** pg_catalog.plpgsql
- **Databases:** sip_development, sip_test

---

## 7. Funcionalidades Implementadas

| Módulo | Estado | Notas |
|--------|--------|-------|
| Bootstrap Rails | ✅ Feito | Rails 8.1.3 + PostgreSQL |
| Modelos base | ✅ Feito | 14 modelos com associações |
| Migrações | ✅ Feito | Schema carregado |
| Auth (Rodauth) | ⏳ Pendente | Gem instalada, não configurada |
| Authorization (Pundit) | ⏳ Pendente | Gem instalada, não configurada |
| Workflow engine | ⏳ Pendente | Estado inicial definido, máquina não implementada |
| Active Storage | ⏳ Pendente | Gem habilitada, configuração necessária |
| Tailwind CSS | ⏳ Pendente | Gem instalada, config necessária |
| CI/CD | ⏳ Pendente | GitHub Actions não configurado |
| Design System | ⏳ Pendente | Nenhum componente criado |

---

## 8. Ponteiros de Atenção

1. **Rodauth não configurado** — Gem instalada mas sem initializer
2. **Pundit não configurado** — Gem instalada mas sem policies
3. **State machine** — `SipProcess` tem `state_machine` referenciado mas gem `state_machine` não no Gemfile
4. **Document Type** — Modelo não existe, referência em `Document`
5. **DiligenceType foreign key** — Referência em `Diligence` mas coluna não existe na migration
6. **GitHub remote** — Não configurado
7. **Master key** — Seed file tem credentials não gerados
8. **Tailwind config** — Não executado `rails tailwind:install`
9. **Turbo/Stimulus** — Instalados mas não integrados nos layouts

---

## 9. Próximos Passos (Fase 1 Continuação)

1. Adicionar gem `state_machines` para workflow
2. Configurar Rodauth initializer
3. Configurar Pundit e criar políticas base
4. Criar modelo `DocumentType`
5. Corrigir foreign key em `Diligence`
6. Configurar Tailwind CSS
7. Configurar Turbo + Stimulus nos layouts
8. Criar seed de perfis e capacidades
9. Configurar Active Storage
10. Criar primeiro controller (Users ou Organizations)

---

## 10. Evidence

- Evidence registrada: `ev_1789409266119_c936`
- Missão: `task-1789408906692`
- Fase atual: discovery → classifying → executing

---

*Documento gerado por Behavior OS orchestrator em 2026-09-14*
