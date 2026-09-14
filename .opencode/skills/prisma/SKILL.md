---
name: prisma
description: >
  Prisma 7 — generator prisma-client with output required.
  Source: https://prisma.io/docs/guides/upgrade/v7. Pnpm-first.
---

# prisma
> Prisma 7

## Generator
```prisma
generator client {
  provider = "prisma-client"
  output   = "../src/generated/prisma"
}
```

## Commands
```bash
pnpm exec prisma generate
pnpm exec prisma migrate dev
```
