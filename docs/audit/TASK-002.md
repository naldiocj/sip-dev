# TASK-002 — Perfis, Capabilities e Estrutura Organizacional SIC Angola

**Status:** ✅ CONCLUÍDO
**Data:** 2026-09-14
**Agente:** orchestrator
**Risco:** R3 (authz + organização)

---

## Arquitetura de Autorização

```
UTILIZADOR
    │
    ▼
 PERFIL (o que pode fazer)
    │
    ├── CAPABILIDADES (acções atómicas)
    │       PROCESSO_VIEW, PROCESSO_CREATE, ...
    │
    ├── FUNÇÃO (cargo organizacional)
    │       DIRETOR_GERAL, INSTRUTOR, ...
    │
    ▼
 ORGANIZAÇÃO (onde trabalha)
    │
    ▼
 SCOPE (quais dados vê)
    │  organizations.pluck(:id)
    │  responsavel_id
    │  criador_id
    ▼
 COMPETÊNCIA (actos permitidos no âmbito)
    │  distribute? assign? return? submit?
    ▼
 PROCESSO
```

---

## 8 Perfis Funcionais (SIC Angola)

| Código | Designação | Capabilidades | Pode Distribuir? |
|--------|-----------|---------------|-----------------|
| `ADMIN` | Administrador do Sistema | 8 | ❌ Não (técnico) |
| `DIRECAO_GERAL` | Direcção-Geral | 18 | ✅ Sim |
| `DIRECAO` | Direcção | 20 | ✅ Sim |
| `DEPARTAMENTO` | Departamento | 20 | ✅ Sim |
| `SECCAO` | Secção | 16 | ✅ Sim |
| `INSTRUTOR` | Instrutor Processual | 15 | ❌ Não* |
| `PIQUETE` | Efetivo de Piquete | 7 | ✅ Encaminha |
| `PGR` | Efetivo PGR/MP | 18 | ✅ Conforme |

*O INSTRUTOR pode solicitar devolução, conclusão, remessa ou encaminhamento quando previsto pelo fluxo.

---

## 27 Capacidades Granulares

```
Processos:  PROCESSO_VIEW, CREATE, UPDATE, DISTRIBUTE, RETURN, ASSIGN, SUBMIT, CLOSE, ARCHIVE
Documentos: DOCUMENT_VIEW, CREATE, UPDATE, SIGN, SUBMIT
Diligências: DILIGENCIA_CREATE, UPDATE, COMPLETE
Mandados:   MANDADO_VIEW, CREATE, EXECUTE
Tramitação: TRAMITACAO_VIEW, CREATE
Gestão:     USER_MANAGE, PROFILE_MANAGE, ORGANIZATION_MANAGE
Auditoria:  AUDIT_VIEW, SYSTEM_CONFIGURE
```

---

## Hierarquia Organizacional Definitiva

```
ROOT (Serviço de Investigação Criminal)
└── DIRECÇÃO-GERAL (DG)
    │
    ├── 01 — DIACID (Direcção de Investigação de Acidentes)
    │   ├── 🚔 01-PIQ — Piquete de Investigação de Acidentes
    │   └── 📂 01-DPT — Departamento
    │       └── 📄 01-SEC — Secção de Investigação de Acidentes I
    │
    ├── 02 — DCCCPES (Direcção de Combate aos Crimes Contra as Pessoas)
    │   ├── 🚔 02-PIQ
    │   └── 📂 02-DPT
    │       └── 📄 02-SEC
    │
    ├── 03 — DCCCPAT (Direcção de Combate aos Crimes Contra o Património)
    │   ├── 🚔 03-PIQ
    │   └── 📂 03-DPT
    │       └── 📄 03-SEC
    │
    ├── 04 — DCCFF (Direcção de Combate aos Crimes Financeiros e Fiscais)
    │   ├── 🚔 04-PIQ
    │   └── 📂 04-DPT
    │       └── 📄 04-SEC
    │
    ├── 05 — DCCORG (Direcção de Combate ao Crime Organizado)
    │   ├── 🚔 05-PIQ
    │   └── 📂 05-DPT
    │       └── 📄 05-SEC
    │
    ├── 06 — DCOP (Direcção Central de Operações)
    │   ├── 🚔 06-PIQ
    │   └── 📂 06-DPT
    │       └── 📄 06-SEC
    │
    ├── 07 — DCN (Direcção de Combate ao Narcotráfico)
    │   ├── 🚔 07-PIQ
    │   └── 📂 07-DPT
    │       └── 📄 07-SEC
    │
    ├── 08 — DCTPMPCA (Direcção de Combate ao Tráfico de Pedras, Metais Preciosos e Crimes Contra o Ambiente)
    │   ├── 🚔 08-PIQ
    │   └── 📂 08-DPT
    │       └── 📄 08-SEC
    │
    ├── 09 — DCCESP (Direcção de Combate ao Crime Contra a Economia e Saúde Pública)
    │   ├── 🚔 09-PIQ
    │   └── 📂 09-DPT
    │       └── 📄 09-SEC
    │
    ├── 10 — DAMCL (Direcção de Atendimento ao Menor em Conflito com a Lei)
    │   ├── 🚔 10-PIQ
    │   └── 📂 10-DPT
    │       └── 📄 10-SEC
    │
    ├── 11 — DCCCI (Direcção de Combate ao Crime Cibernético)
    │   ├── 🚔 11-PIQ
    │   └── 📂 11-DPT
    │       └── 📄 11-SEC
    │
    └── 12 — DCCC (Direcção de Combate ao Crime de Corrupção)
        ├── 🚔 12-PIQ
        └── 📂 12-DPT
            └── 📄 12-SEC
```

**Total:** 50 organizações (1 ROOT + 1 DG + 12 Direções × 4 unidades cada)

---

## Regras de Hierarquia (Validação)

```ruby
CHILD_LEVELS = {
  'root'         => %w[direccao_geral],
  'direccao_geral' => %w[direccao],
  'direccao'     => %w[piquete departamento],
  'departamento' => %w[seccao],
  'piquete'      => [],
  'seccao'       => []
}
```

**Importante:** Piquete e Departamento são **irmãos** dentro da Direção.

---

## Credenciais de Teste

```
URL:      http://localhost:3000/auth/login
Email:    director@sic.gov.ao
Password: Sic@2024Angola
Perfil:   DIRECAO_GERAL
Org:      ROOT (Serviço de Investigação Criminal)
```

---

## Quality Gates

| Tool | Resultado |
|------|-----------|
| RuboCop | ✅ 0 offenses |
| Brakeman | ✅ 0 warnings, 0 errors |
| RSpec | ✅ 17 examples, 0 failures |

---

## Evidence

- Evidence ID: `ev_1789413051876_1xyt`
- Mission ID: `task-1789408906692`
- Phase: executing → evidenced

---

*TASK-002 concluída. Pronto para TASK-003 (Seed + Tailwind + Turbo).*
