---
name: creator
description: >
  Creator skill — análise profunda do projeto antes de qualquer implementação.
  Varre stack, arquitetura, padrões, versões e sugere melhorias antes de construir.
  Obrigatório antes de execute (SkillGate). Use para SaaS, fintech e qualquer
  projeto enterprise. Pnpm-first, monorepo-aware.
---

# Creator — Project Analysis Before Build

## Quando usar
- Sempre antes de `execute` (workflow enterprise exige `skill-acquisition`)
- Quando `dna: enterprise` ou qualquer agente precisa entender o projeto
- Antes de criar SaaS, fintech, e-commerce, ou feature crítica

## O que faz
1. **Workspace Discover** — lê `pnpm-workspace.yaml`, `turbo.json`, `apps/*`, `packages/*`, `package.json` de cada workspace
2. **Stack truth** — verifica versões reais vs policy (`bos_truth` para cada tech)
3. **Architecture scan** — `glob` + `grep` para padrões, `src/discovery/architecture.ts` (monolito, camadas, anti-patterns)
4. **Gap analysis** — compara com `enterprise.yaml` gates e sugere melhorias
5. **Knowledge pack** — gera `.behavior-os/knowledge/task-<id>/creator-report.md`

## Fluxo obrigatório
```
creator → bos_discover (full) → bos_truth (cada stack) → grep architecture → bos_knowledge → report
```

## Ferramentas permitidas
`read`, `glob`, `grep`, `bos_discover`, `bos_truth`, `bos_knowledge`, `webfetch`

## Saída
- `creator-report.md` com:
  - Stack detectada (com versões e status LTS/EOL)
  - Topologia monorepo (workspaces, turbo pipelines)
  - Arquitetura atual (diagrama + anti-patterns)
  - Gaps vs enterprise (ex: sem `prisma output`, sem `turbopack.root`)
  - Sugestões priorizadas (P0/P1/P2)
  - Skills recomendadas para a missão (ex: `backend-architecture`, `database`, `security`)

## Regras
- Nunca assumir — sempre verificar com `bos_truth`
- Nunca propor sem evidência de `glob`/`read`
- Pnpm-first: sugerir `pnpm -F <pkg>` para comandos por workspace
- Registrar `SkillGate: PASS` em `.behavior-os/state/state.json` após concluir

## Exemplo de uso pelo orchestrator
```
1. skill: creator (análise)
2. bos_discover scope full
3. bos_truth tech=prisma check=breaking-changes
4. bos_knowledge taskId=creator-<date> context={stack, gaps}
5. Prosseguir para plan/execute só se SkillGate PASS
```
