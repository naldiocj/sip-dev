---
name: prisma-7
description: >
  Prisma 7 — generator prisma-client with output required, prisma.config.ts.
  Source: https://prisma.io/docs/guides/upgrade/v7.
---

# prisma-7
> Prisma 7 | output required

## Generator
```prisma
generator client { provider = "prisma-client" output = "../src/generated/prisma" }
```

## Workflow
1. bos_truth tech=prisma
2. pnpm exec prisma generate
