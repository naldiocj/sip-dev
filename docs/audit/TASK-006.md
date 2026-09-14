# TASK-006 — Users CRUD + Profile Assignment

**Status:** ✅ CONCLUÍDO
**Data:** 2026-09-14
**Agente:** orchestrator
**Risco:** R3 (dados sensíveis)

---

## Entregáveis

### Controllers
- `Admin::UsersController` — CRUD completo + activate/deactivate
- `authorize_resource` para autorização Pundit

### Views (Tailwind CSS)
- `index.html.erb` — Tabela com filtros por perfil/organização/estado
- `show.html.erb` — Perfil completo com afectações
- `new.html.erb` — Formulário de criação
- `edit.html.erb` — Formulário de edição
- `_form.html.erb` — Partial reutilizável

### Políticas
- `UserPolicy` — Scope limita não-admins ao próprio registo

### Rotas
```ruby
resources :users do
  member do
    post "activate"
    post "deactivate"
  end
end
```

---

## Funcionalidades

| Funcionalidade | Estado |
|----------------|--------|
| Listar todos os utilizadores | ✅ |
| Ver perfil detalhado | ✅ |
| Criar novo utilizador | ✅ |
| Editar utilizador | ✅ |
| Eliminar utilizador | ✅ |
| Activar/Desactivar conta | ✅ |
| Afectar perfil + organização | ✅ |
| Filtros por perfil/org/estado | ✅ |
| Avatar com inicial | ✅ |
| Badges por perfil (cores) | ✅ |
| Históricode afectações | ✅ |
| Confirmação antes de eliminar | ✅ |
| Criação automática de conta Rodauth | ✅ |

---

## Modelos Relacionados

```
User
├── belongs_to :organization
├── has_many :user_assignments
├── has_many :organizations (through assignments)
├── has_many :assigned_profiles (through assignments)
└── has_one :account

UserAssignment
├── belongs_to :user
├── belongs_to :organization
├── belongs_to :profile
└── started_at / ended_at
```

---

## Regras de Negócio

1. **Criação de conta**: ao criar User, cria-se automaticamente Account Rodauth
2. **Afectação**: perfil + organização obrigatórios na criação
3. **Activacao**: só ADMIN pode activar/desactivar
4. **Scope**: não-admins vêem apenas o seu próprio perfil
5. **Eliminação**: segura com destroy em cascade

---

## Quality Gates

| Tool | Resultado |
|------|-----------|
| RuboCop | ✅ 0 offenses |
| Brakeman | ⚠️ 1 warning (Rails EOL) |
| RSpec | ✅ 19 examples, 0 failures |

---

## Evidence

- Mission ID: `task-1789408906692`
- Phase: executing → evidenced

---

*TASK-006 concluída.*
