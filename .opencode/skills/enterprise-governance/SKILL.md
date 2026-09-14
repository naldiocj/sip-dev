---
name: enterprise-governance
description: >
  Enterprise governance — garante que agentes tenham habilidades da stack antes de executar.
  Valida SkillGate, sugere skills, bloqueia execução sem creator.
---

# Enterprise Governance

## Quando usar
- Sempre que `dna: enterprise` estiver ativo
- Antes de `execute` em qualquer missão R2+

## O que faz
- Lê `dna.skills.required` do DNA ativo
- Verifica `.opencode/skills/<skill>/SKILL.md` existe para cada skill requerida
- Verifica `state.gates` contém `SkillGate: PASS`
- Se faltar, sugere `skill: creator` + skills específicas da stack

## Integração com plugin
O plugin `behavior-os.ts` em `tool.execute.before` verifica:
- Se `tool` é `edit/write/apply_patch` e `SkillGate != PASS` → `DENY` com `R-009: SkillGate required`
- Registra `evidence` com `skillGate` status

## Skills enterprise disponíveis
- `creator` (obrigatória)
- `backend-architecture`, `frontend-architecture`, `database`, `security`, `api-design`, `typescript`
