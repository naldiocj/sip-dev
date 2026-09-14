---
name: better-auth
description: >
  Better Auth — prismaAdapter, auth generate.
  Source: https://www.better-auth.com/docs. Pnpm-first.
---

# better-auth
> prismaAdapter(prisma, {provider: "postgresql"})

## Install
```bash
pnpm add better-auth @better-auth/prisma-adapter
pnpm dlx @better-auth/cli generate --config auth.ts
```

## Pattern
```ts
import { betterAuth } from "better-auth"
import { prismaAdapter } from "better-auth/adapters/prisma"
export const auth = betterAuth({ database: prismaAdapter(prisma, {provider: "postgresql"}) })
```
