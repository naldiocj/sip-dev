---
name: behavior-os
description: >
  Governance kernel for AI-assisted development. Classifies operations by risk,
  enforces policies, tracks state transitions, and maintains execution evidence.
  Use when starting any development session, before file edits, or when
  orchestrating multi-agent workflows.
---

# Behavior OS — System Operating Orchestrator

## Visão Geral

Behavior OS é um **System Operating Orchestrator for Software Engineering Agents**.

Não compete com OpenCode — o integra e governa.

## Arquitetura

```
                    BEHAVIOR OS
                         │
          ┌──────────────┼──────────────┐
          │              │              │
        DNA           POLICY         ORCHESTRATOR
          │              │              │
   "como trabalhar"   "o que permitir"  "quando e quem"
          │              │              │
          └──────────────┼──────────────┘
                         │
                   OpenCode Runtime
                         │
          ┌──────────────┼──────────────┐
          │              │              │
        Agents        Permissions     Tools
          │              │              │
          └──────────────┼──────────────┘
                         │
                     Execution
                         │
                   Evidence
```

## 7 Garantias (Fail-Closed)

| # | Garantia | Como é enforced |
|---|----------|-----------------|
| 1 | **Discovery** | Gate bloqueia execution se discovery incompleto |
| 2 | **Truth** | Tool `bos_truth` requer verificação em fontes oficiais |
| 3 | **Version** | Version policy no DNA (LTS-first, no EOL) |
| 4 | **Behavior** | DNA define princípios e workflow obrigatório |
| 5 | **Policy** | Permissions do OpenCode controlam acesso |
| 6 | **Validation** | Gates type/lint/test devem passar |
| 7 | **Evidence** | EvidenceGate bloqueia DONE sem evidência |

## Workflow Obrigatório

```
DISCOVER → CLASSIFY → TRUTH → KNOWLEDGE → PLAN → EXECUTE → VALIDATE → EVIDENCE → DONE
```

**Nunca pular etapas.** Se um gate falhar:
```
FAIL → DIAGNOSE → FIX → REVALIDATE
```

## Quando usar

- Iniciar nova sessão de desenvolvimento
- Antes de executar qualquer `edit`, `write`, ou `bash` R2+
- Ao orquestrar múltiplos agentes (handoff)
- Quando necessário avaliar risco de uma operação
- Ao registrar evidência de execução

## Custom Tools

| Tool | Função |
|------|--------|
| `bos_discover` | Descobre contexto do projeto (stack, versões) |
| `bos_truth` | Resolve truth sobre tecnologia (versões, APIs) |
| `bos_knowledge` | Constrói knowledge pack por missão |
| `bos_validate` | Executa gates de validação (type, lint, test) |
| `bos_evidence` | Registra evidência de execução |

## Comandos

| Command | Função |
|---------|--------|
| `/discover` | Roda discovery completo |
| `/validate` | Executa gates de validação |
| `/evidence` | Mostra evidências da sessão |
| `/doctor` | Verifica saúde do sistema |

## Estrutura `.behavior-os/`

```
.behavior-os/
├── truth/           # Truth Base (versões, stack)
├── knowledge/       # Knowledge Packs por missão
├── state/           # Estado da missão
├── evidence/        # Evidências
├── dna/             # DNAs dos agentes
└── profiles/        # Stack Profiles
```

## Stack Profiles

Carregados automaticamente conforme stack detectada:
- `node.yaml` — runtime Node.js
- `typescript.yaml` — strict mode, no-any
- `nestjs.yaml` — modules, controllers, services

## DNAs (Comportamento)

| DNA | Papel | Permissões |
|-----|-------|------------|
| `orchestrator` | Coordena workflows | task: allow (selected) |
| `backend` | Dev backend | edit: allow, bash: controlled |
| `frontend` | Dev frontend | edit: allow, bash: controlled |
| `qa` | Testes | edit: deny, bash: test-only |
| `governance` | Auditoria | read-only total |

## Regras Fundamentais

1. **Nunca assumir versão** — sempre verificar com `bos_truth`
2. **Nunca usar API sem fonte oficial** — consultar `sources.yaml`
3. **Nunca finalizar sem evidência** — registrar antes de DONE
4. **Nunca ignorar gates** — fail-closed: se falhar, não avança
