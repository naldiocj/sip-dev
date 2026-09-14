---
name: architecture-discovery
description: >
  Descobre e compreende a arquitetura real de qualquer projeto antes de alterar código.
  Inspeciona AGENTS.md, package.json, pnpm-workspace, turbo.json, apps/packages, testes, CI/CD.
  Produz relatório factual em .ai/evidence/architecture-discovery.md com FACT/INFERENCE/UNKNOWN/RISK.
---

# architecture-discovery

## Objetivo
Permitir que o agente descubra e compreenda a arquitetura real de qualquer projeto antes de alterar código.

## Regras

Inspeciona primeiro:
- AGENTS.md
- INSTRUCTIONS.md
- README.md
- STACK.md
- VISION.md
- package.json
- pnpm-workspace.yaml
- turbo.json
- tsconfig*
- estrutura de apps/ e packages/
- documentação existente
- configuração de testes
- configuração de CI/CD

Não assumes a arquitetura pelo nome das pastas.
Confirma através do código, dependências e configurações reais.

Identifica:
- frontend
- backend
- APIs
- database
- ORM
- autenticação
- autorização
- cache
- filas
- storage
- observabilidade
- testes
- CI/CD
- monorepo
- packages compartilhados

Identifica também:
- entrypoints
- módulos
- boundaries
- dependências entre módulos
- padrões utilizados
- anti-patterns
- código duplicado
- mocks
- TODOs críticos
- integrações incompletas

Antes de recomendar uma mudança, verifica a implementação existente.
Não modifica código durante discovery.

## Saída
Produz um relatório factual em:
`.ai/evidence/architecture-discovery.md`

O relatório deve separar claramente:

- **FACT** — comprovado pelo código/configuração
- **INFERENCE** — inferência razoável
- **UNKNOWN** — informação ainda não comprovada
- **RISK** — risco identificado

Nunca transforme uma inferência em fato.

## Reutilização
A skill deve ser reutilizável em qualquer stack e não pode assumir Next.js, NestJS, Prisma ou qualquer framework específico.

## Workflow Behavior OS
1. `read` AGENTS.md, README.md, package.json, pnpm-workspace.yaml
2. `glob` apps/*, packages/*
3. `grep` entrypoints, boundaries
4. `bos_discover` (full)
5. Gerar `.ai/evidence/architecture-discovery.md`
