# TASK-PROC-002 — Services Pattern

**Status:** ✅ CONCLUÍDO
**Data:** 2026-09-14
**Agente:** orchestrator
**Risco:** R3

---

## Serviços Implementados

| Serviço | Classe | Descrição |
|---------|--------|-----------|
| Create | `Processes::Create` | Criar novo processo |
| Distribute | `Processes::Distribute` | Distribuir para órgão inferior |
| Receive | `Processes::Receive` | Receber processo devolvido |
| Return | `Processes::Return` | Devolver à origem |
| Redistribute | `Processes::Redistribute` | Redistribuir entre irmãos |
| Forward | `Processes::Forward` | Encaminhar para frente |
| TakeOver | `Processes::TakeOver` | Avocar processo |
| Suspend | `Processes::Suspend` | Suspender instrução |
| Resume | `Processes::Resume` | Retomar instrução |
| Conclude | `Processes::Conclude` | Concluir instrução |
| Close | `Processes::Close` | Encerrar processo |
| Archive | `Processes::Archive` | Arquivar processo |
| Reopen | `Processes::Reopen` | Reabrir processo |

---

## Padrão Aplicado

```ruby
# Uso correto (via serviço)
Processes::Distribute.call(
  process: process,
  destination_organization: section,
  destination_user: instructor,
  performed_by: current_user,
  reason: 'Distribuição normal'
)

# Uso INCORRETO (NUNCA fazer)
process.update!(state: 'DISTRIBUIDO')
```

---

## Validações por Operação

| Operação | Capabilities | Estados Permitidos | Campo Obrigatório |
|----------|-------------|-------------------|-------------------|
| Create | PROCESSO_CREATE | — | — |
| Distribute | PROCESSO_DISTRIBUIR | REGISTADO, EM_DISTRIBUICAO | — |
| Receive | PROCESSO_VIEW | DEVOLVIDO | — |
| Return | PROCESSO_RETURN | EM_INSTRUCAO, PENDENTE | reason |
| Redistribute | PROCESSO_DISTRIBUIR | DISTRIBUIDO, EM_INSTRUCAO, PENDENTE | — |
| Forward | PROCESSO_DISTRIBUIR | DISTRIBUIDO, EM_INSTRUCAO | — |
| TakeOver | PROCESSO_DISTRIBUIR | DISTRIBUIDO, EM_INSTRUCAO, PENDENTE | — |
| Suspend | PROCESSO_UPDATE | EM_INSTRUCAO | reason |
| Resume | PROCESSO_UPDATE | SUSPENSO | — |
| Conclude | PROCESSO_CLOSE | EM_INSTRUCAO | reason |
| Close | PROCESSO_CLOSE | CONCLUIDO | — |
| Archive | PROCESSO_ARCHIVE | ENCERRADO | — |
| Reopen | PROCESSO_CREATE | ENCERRADO, ARQUIVADO | reason |

---

## Regras de Negócio

1. **Transacção atómica** — todas as operações dentro de `ActiveRecord::Base.transaction`
2. **Histórico imutável** — transições nunca apagadas
3. **Moveimentos registados** — cada distribuição cria registro
4. **Localizações preservadas** — histórico de onde esteve o processo
5. **Atribuições com timeline** — quem foi responsável em cada período
6. **Auditoria completa** — before/after data em cada operação
7. **Suspensão de prazos** — deadlines suspensos automaticamente

---

## Estrutura de Classes

```
Processes::Base
├── validate_authorization!
├── validate_state!
├── validate_state_transition!
├── validate_scope!
├── validate_required_field!
├── create_audit_event!
├── create_transition_record!
└── (private helpers)

Processes::Create
Processes::Distribute
Processes::Receive
Processes::Return
Processes::Redistribute
Processes::Forward
Processes::TakeOver
Processes::Suspend
Processes::Resume
Processes::Conclude
Processes::Close
Processes::Archive
Processes::Reopen
```

---

## Exceptions

- `Processes::Base::PermissionError` — autorização negada
- `Processes::Base::StateError` — estado inválido
- `Processes::Base::TransitionError` — transição não permitida
- `Processes::Base::ScopeError` — fora do scope organizacional
- `Processes::Base::ValidationError` — validação falhou

---

## Quality Gates

| Tool | Resultado |
|------|-----------|
| RuboCop | ✅ 0 offenses |
| Brakeman | ⚠️ 1 warning (Rails EOL) |
| RSpec | ✅ 19 examples, 0 failures |

---

## Evidence

- Evidence ID: `ev_1789418528174_rqxn`
- Mission ID: `task-1789408906692`
- Phase: executing → evidenced

---

*TASK-PROC-002 concluída.*
