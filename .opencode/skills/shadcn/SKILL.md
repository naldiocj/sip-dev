---
name: shadcn
description: >
  shadcn/ui official skill — project-aware context for AI coding agents.
  Knows how to find, install, compose and customize components using correct APIs.
  Source: https://ui.shadcn.com/docs/skills (official) + https://ui.shadcn.com/docs/cli
  Pnpm-first, Tailwind v4, Next.js 16, monorepo.
---

# shadcn/ui — Official Skill

> **Install oficial:** `pnpm dlx skills add shadcn/ui` (via https://skills.sh)
> **Fonte:** https://ui.shadcn.com/docs/skills + https://ui.shadcn.com/docs/cli
> **Stack:** Next.js 16 (App Router, Turbopack), Tailwind v4, Radix/Base UI, pnpm

## Instalação da Skill Oficial (recomendado)

```bash
pnpm dlx skills add shadcn/ui
```
A skill oficial injeta contexto do projeto via `shadcn info --json` (framework, Tailwind version, aliases, base library `base|radix|aria`, icon library, installed components, file paths) e ensina o agente a usar CLI corretamente.

**O que a skill oficial entrega (ui.shadcn.com/docs/skills#whats-included):**
- **Project Context** — roda `shadcn info --json` a cada interação
- **CLI Commands** — `init`, `add`, `search`, `view`, `docs`, `diff`, `info`, `build`, `preset`, `migrate`, `eject` + flags, dry-run, smart merge
- **Theming** — CSS variables, OKLCH, dark mode, custom colors, radius, variants (Tailwind v3 e v4)
- **Registry Authoring** — `registry.json`, item types, building, hosting
- **MCP Server** — search/browse/install via MCP quando `skills` não basta

## CLI Oficial (ui.shadcn.com/docs/cli)

### init — inicializa ou cria projeto
```bash
pnpm dlx shadcn@latest init
# opções: -t next|vite|start -b base|radix|aria -p [preset] --monorepo --css-variables/--no-css-variables
pnpm dlx shadcn@latest init -t next --monorepo
pnpm dlx shadcn@latest create # alias de init com --name
```

### add — adiciona componente
```bash
pnpm dlx shadcn@latest add [component]
pnpm dlx shadcn@latest add button
pnpm dlx shadcn@latest add button card dialog --dry-run
pnpm dlx shadcn@latest add button -c apps/web  # monorepo
pnpm dlx shadcn@latest add https://www.shadcn.io/r/card.json # registry custom
```

### Outros comandos oficiais
```bash
pnpm dlx shadcn@latest search -q "button"          # busca
pnpm dlx shadcn@latest view button card            # preview
pnpm dlx shadcn@latest docs button --json          # docs da API
pnpm dlx shadcn@latest info --json                 # project context
pnpm dlx shadcn@latest diff button                 # diff
pnpm dlx shadcn@latest preset decode a2r6bw        # preset
pnpm dlx shadcn@latest migrate cn                  # migra clsx/tailwind-merge → cn
pnpm dlx shadcn@latest migrate icons --from lucide --to phosphor
pnpm dlx shadcn@latest eject                       # inlines shadcn/tailwind.css
```

## Configuração Next.js 16 + Tailwind v4 (oficial)

### Tailwind v4 — CSS-first (sem tailwind.config.js)
```css
/* src/app/globals.css */
@import "tailwindcss";
@import "tw-animate-css";
@import "shadcn/tailwind.css";
@theme { --font-display: "Inter", sans-serif; }
```
```js
// postcss.config.mjs
export default { plugins: { "@tailwindcss/postcss": {} } }
```

### Alias e components.json
```json
// tsconfig.json
{ "compilerOptions": { "paths": { "@/*": ["./src/*"] } } }
// components.json (gerado por init)
{ "style": "new-york", "tailwind": { "css": "src/app/globals.css", "baseColor": "zinc" }, "aliases": { "utils": "@/lib/utils", "components": "@/components" } }
```

### Monorepo (turborepo + pnpm)
```js
// apps/web/next.config.js
module.exports = { turbopack: { root: "../../" }, outputFileTracingRoot: "../../" }
// run from workspace:
pnpm dlx shadcn@latest add button -c apps/web
```

## Como a Skill Oficial Funciona (ui.shadcn.com/docs/skills#how-it-works)
1. Detecta `components.json`
2. Injeta `shadcn info --json`
3. Enforce patterns: `FieldGroup` para forms, `ToggleGroup` para options, semantic colors, base-specific APIs (base vs radix vs aria)
4. Usa `shadcn docs/search` ou MCP antes de gerar código

## Uso com Behavior OS

**Antes de qualquer `edit` com shadcn:**
```bash
skill: shadcn          # carrega skill oficial
bos_discover           # detecta Next 16 + Tailwind v4
bos_truth tech=shadcn  # verifica breaking changes
bos_skill acquire skill=shadcn  # SkillGate PASS
# então:
pnpm dlx shadcn@latest add button --dry-run
pnpm dlx shadcn@latest add button
```

**Exemplos que a skill já entende (oficial):**
- "Add a login form with email and password fields."
- "Create a settings page with a form for updating profile information."
- "Build a dashboard with a sidebar, stats cards, and a data table."

## Fontes Oficiais
- https://ui.shadcn.com/docs/skills (skill oficial)
- https://ui.shadcn.com/docs/cli (CLI completo)
- https://ui.shadcn.com/docs/installation/next (Next.js)
- https://ui.shadcn.com/docs/theming (OKLCH, dark mode)
- https://ui.shadcn.com/docs/monorepo
- https://skills.sh (registry de skills)
