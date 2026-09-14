---
name: backend-architecture
description: >
  Auto-generated skill for backend-architecture — TypeScript strict, backend patterns.
  Source: https://www.typescriptlang.org/docs. Version: not-installed.
  Generated via bos_skill create with truth verification. Pnpm-first.
---

# backend-architecture

> Auto-generated from official docs: https://www.typescriptlang.org/docs
> Tech: typescript | Version: not-installed | Generated: 2026-09-10

## Stack
- Tech: typescript
- Source: https://www.typescriptlang.org/docs
- Desc: TypeScript strict, backend patterns

## Truth
- Version: not-installed
- Run bos_truth tech=typescript to verify
- Policy: pnpm-first, lts channel

## Patterns
- Use pnpm -F <package> for monorepo workspaces
- Follow official docs for typescript breaking changes
- TypeScript strict, no any

## Anti-patterns
- Never assume version — verify with bos_truth
- Never use unverified API

## Workflow
1. bos_discover (full)
2. bos_truth tech=typescript
3. Implement with typescript best practices
4. bos_validate gates=[type,lint,test]
5. bos_evidence

## Evidence
Skill created via bos_skill create, truth verified, version not-installed
