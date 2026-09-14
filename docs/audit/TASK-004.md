# TASK-004 — Tailwind CSS + Turbo + Stimulus Integration

**Status:** ✅ CONCLUÍDO
**Data:** 2026-09-14
**Agente:** orchestrator
**Risco:** R2

---

## Stack JavaScript Configurada

| Gem | Versão | Função |
|-----|--------|--------|
| `turbo-rails` | 2.0.23 | Navegação SPA sem rebuild |
| `stimulus-rails` | 1.3.4 | Controllers JavaScript declarativos |
| `importmap-rails` | 2.2.3 | Importações de pacotes npm |
| `tailwindcss-rails` | 3.3.2 | Utility-first CSS |

---

## Estrutura de Arquivos Criados

```
app/
├── javascript/
│   ├── application.js           # Entry point (Turbo + Stimulus)
│   └── controllers/
│       ├── application.js       # Aplicação Stimulus base
│       ├── index.js             # Loader automático
│       └── hello_controller.js  # Exemplo
├── views/
│   ├── layouts/
│   │   └── application.html.erb # Layout principal com sidebar
│   └── shared/
│       ├── sidebar/_menu.html.erb      # Menu dinâmico por perfil
│       └── _sidebar_helpers.html.erb   # Helpers de navegação
└── controllers/
    ├── application_controller.rb      # Auth + Pundit base
    ├── auth_controller.rb             # Login/Logout session-based
    ├── welcome_controller.rb          # Landing page
    └── admin/
        └── dashboard_controller.rb    # Dashboard principal
```

---

## Design System Tailwind

### Components Criados

| Componente | Classes | Uso |
|------------|---------|-----|
| `.btn` | Base button com transição | Botões gerais |
| `.btn-primary` | Azul, branco texto | Ação principal |
| `.btn-secondary` | Branco, borda cinza | Ação secundária |
| `.btn-danger` | Vermelho | Ações destrutivas |
| `.card` | Borda, shadow, rounded | Conteúdo agrupado |
| `.badge-*` | Color badges | Status, tags |
| `.alert-*` | Color alerts | Mensagens flash |
| `.table` | Table styling | Listagens |
| `.nav-link` | Sidebar links | Navegação |
| `.sidebar` | Sidebar wrapper | Layout sidebar |
| `.stat-card` | Dashboard stats | Métricas |

---

## Autenticação

**Fluxo:**
1. Usuário acessa `/auth/login`
2. Rodauth valida credenciais
3. Session Rails criada (`session[:account_id]`, `session[:user_id]`)
4. Redireciona para `/admin/dashboard`
5. Logout limpa session

**Credenciais de teste:**
```
Email:    director@sic.gov.ao
Password: Sic@2024Angola
Perfil:   DIRECAO_GERAL
Org:      ROOT (Serviço de Investigação Criminal)
```

---

## Menu Dinâmico por Perfil

O sidebar mostra links baseados nas capacidades do perfil:
- **ADMIN**: Organizações, Utilizadores, Perfis, Capacidades, Auditoria
- **DIRECAO_GERAL**: Dashboard, Processos, Diligências, Documentos, Mandados, Evidências, Auditoria
- **INSTRUTOR**: Dashboard, Processos (apenas atribuídos), Diligências
- **PIQUETE**: Dashboard, Processos (criar), Documentos

---

## Quality Gates

| Tool | Resultado |
|------|-----------|
| RuboCop | ✅ 0 offenses |
| Brakeman | ✅ 0 warnings, 0 errors |
| RSpec | ✅ 17 examples, 0 failures |

---

## Evidence

- Mission ID: `task-1789408906692`
- Phase: executing → evidenced

---

*TASK-004 concluída. Pronto para TASK-005 (Organizations CRUD).*
