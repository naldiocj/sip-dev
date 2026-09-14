# TASK-003 — Seed Files Estruturados

**Status:** ✅ CONCLUÍDO
**Data:** 2026-09-14
**Agente:** orchestrator
**Risco:** R2

---

## Estrutura de Seeds

```
db/
├── seeds.rb                     # Entry point — executa todos os seeds na ordem
└── seeds/
    ├── 01_capabilities.rb       # 27 capacidades atómicas
    ├── 02_profiles.rb           # 8 perfis com mapping de capabilities
    ├── 03_organizations.rb      # 50 organizações (hierarquia SIC)
    ├── 04_users.rb              # Admin + conta Rodauth
    ├── 05_process_types.rb      # 6 tipos de processo
    └── 06_diligence_types.rb    # 10 tipos de diligência
```

---

## Princípios Aplicados

1. **Idempotência** — todos os seeds verificam existência antes de criar
2. **Ordem explícita** — número-prefixed garante execução correcta
3. **Separação por domínio** — cada ficheiro trata um conceito único
4. **Config externalizada** — senhas vêm de `ENV` ou default seguro
5. **Sem `rails runner`** — tudo centralizado em seeds

---

## Execução

```bash
# Production
bin/rails db:seed

# Teste
RAILS_ENV=test bin/rails db:seed

# Reset completo
bin/rails db:reset   # drop + create + migrate + seed
```

---

## Dados Criados

| Entidade | Quantidade |
|----------|-----------|
| Capacidades | 27 |
| Perfis | 8 |
| Organizações | 50 (12 direções × 4 unidades) |
| Users | 1 (admin) |
| Accounts | 1 (Rodauth) |
| Process Types | 6 |
| Diligence Types | 10 |

---

## Credenciais

```
URL:      http://localhost:3000/auth/login
Email:    director@sic.gov.ao
Password: Sic@2024Angola (ou definir SIP_ADMIN_PASSWORD=no .env)
```

---

## Evidence

- Mission ID: `task-1789408906692`
- Phase: executing → evidenced

---

*TASK-003 concluída.*
