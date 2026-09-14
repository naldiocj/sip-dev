---
name: forms
description: >
  Forms — react-hook-form + zod v4 (z.compile, toJSONSchema).
  Source: https://react-hook-form.com, https://zod.dev. Pnpm-first.
---

# forms
> RHF + Zod v4

## Install
```bash
pnpm add react-hook-form zod@^4.5.0
pnpm add -D @hookform/resolvers
```

## Pattern
```tsx
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import * as z from "zod"
const schema = z.object({ email: z.email() })
```
