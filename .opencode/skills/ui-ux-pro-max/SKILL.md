---
name: ui-ux-pro-max
description: >
  UI/UX Pro Max — enterprise SaaS design system, calm design, command palette,
  a11y, motion, data-dense patterns. Complementa shadcn/ui para SaaS fintech.
  Fontes: ui.shadcn.com, Tailwind v4, WCAG 2.2, SaaS UI 2026 trends.
---

# UI/UX Pro Max — Enterprise SaaS

> **Para SaaS fintech enterprise:** design system que escala, calm design, command palette, intent-based onboarding
> **Depende de:** `shadcn` (base), `tailwind-v4`, `design-system` | **Stack:** Next 16, Tailwind v4, Radix, pnpm
> **Fontes:** https://ui.shadcn.com/docs, https://www.saasui.design (2026 trends), https://uxpilot.ai/enterprise-ux

## Princípios Enterprise (2026)

### 1. Design System que escala (não só style guide)
- **Elementos:** UI components (tables, forms, filters, modals) + code snippets + typography/color otimizados para sessões longas + interaction patterns (bulk actions, approvals)
- **Impacto:** fintech SaaS case — 50% faster handoff, 34% faster tasks, UI rework 30% → 10%
- **Ferramentas:** Figma Variables + Tokens Studio (JSON) + Storybook + Zeroheight/Notion
- **Comece com 20 componentes** mais usados, não tente cobrir tudo no dia 1

### 2. Calm Design — menos é mais
- Esconder não-essencial por padrão (ex: Linear dashboard — whitespace-heavy, foco no trabalho)
- Sinal: quando designers dizem "feels like Linear" = brand attribute
- Evitar airplane cockpit (muitas features visíveis)

### 3. Command Palette — Cmd+K obrigatório
- Padrão 2026 para SaaS com 10+ features (Linear, Figma, VS Code)
- Toda ação a 1 keystroke, menus não escalam
- Implementar com `shadcn` Command + `cmdk`

### 4. A11y WCAG 2.2 AA + Enterprise
- Radix primitives já a11y, mas verificar: `aria-label`, `focus-visible:ring`, keyboard (Tab/Enter/Esc), contraste AA, `prefers-reduced-motion`
- Enterprise buyers exigem — design system sem a11y é rejeitado em pilot

### 5. Onboarding intent-based + everboarding
- 1 pergunta que reshape experiência (Notion: template sets por resposta)
- Checklist adaptativa (Asana: responde ao comportamento, não static)
- Early "aha moment" → 69% mais retenção 3 meses

## Stack Recomendada (pnpm-first)

| Camada | Tech | Comando |
|--------|------|---------|
| Base | shadcn/ui | `pnpm dlx shadcn@latest add button card dialog data-table` |
| Tokens | Tailwind v4 | `pnpm add -D tailwindcss@latest @tailwindcss/postcss` |
| Motion | framer-motion | `pnpm add framer-motion` |
| Icons | lucide-react | `pnpm add lucide-react` |
| A11y | Radix UI | via shadcn |
| Forms | react-hook-form + zod v4 | `pnpm add react-hook-form zod@^4.5.0` |
| Search | cmdk | via shadcn Command |
| Charts | recharts | `pnpm add recharts` |

## Padrões Enterprise Configuração

### Tokens (Tailwind v4 CSS-first)
```css
/* src/app/globals.css */
@import "tailwindcss";
@import "tw-animate-css";
@import "shadcn/tailwind.css";
@theme {
  --color-primary: oklch(0.5 0.2 240);
  --radius: 0.5rem;
  --font-display: "Inter", sans-serif;
}
```

### Command Palette (shadcn Command)
```tsx
import { Command, CommandInput, CommandList, CommandItem } from "@/components/ui/command"
<Command>
  <CommandInput placeholder="Type a command..." />
  <CommandList>
    <CommandItem onSelect={() => router.push('/payments')}>Go to Payments</CommandItem>
  </CommandList>
</Command>
```

### Data Table (fintech ledger)
```tsx
import { DataTable } from "@/components/ui/data-table" // shadcn data-table (TanStack)
// sticky header, align-right numeric, mono font, bulk actions
```

### Motion com propósito
```tsx
import { motion } from "framer-motion"
<motion.div initial={{opacity:0}} animate={{opacity:1}} transition={{duration:0.2}} />
// respeitar prefers-reduced-motion
```

## Workflow Behavior OS

1. `skill: shadcn` (base, via `pnpm dlx skills add shadcn/ui` + `shadcn info --json`)
2. `skill: ui-ux-pro-max` (este)
3. `bos_discover` (Next 16 + Tailwind v4 + workspaces)
4. `bos_truth tech=tailwind` + `bos_truth tech=shadcn`
5. `pnpm dlx shadcn@latest add data-table skeleton form command`
6. Implementar com tokens + a11y + calm design + command palette
7. `bos_validate gates=[type, lint, accessibility]`

## Outras Skills Sugeridas (criar via `bos_skill create`)

| Skill | Quando usar | Fonte |
|-------|-------------|-------|
| `tailwind-v4` | Tokens, `@theme`, PostCSS | tailwindcss.com |
| `accessibility` | WCAG audit, axe-core | w3.org/WAI |
| `motion` | Framer Motion, `prefers-reduced-motion` | motion.dev |
| `forms` | RHF + Zod v4, `z.compile` | zod.dev, react-hook-form.com |
| `data-viz` | Charts, tables densas para ledger | recharts.org, TanStack Table |
| `better-auth` | Auth, `prismaAdapter` | better-auth.com |
| `prisma` | DB, `generator output` v7 | prisma.io/docs |
| `command-palette` | Cmd+K, `cmdk` | shadcn Command |

## Fontes Oficiais
- https://ui.shadcn.com/docs/skills (skill oficial, project-aware)
- https://ui.shadcn.com/docs/cli (CLI init/add/search/view)
- https://ui.shadcn.com/docs/theming (OKLCH, dark mode)
- https://ui.shadcn.com/docs/monorepo
- https://www.saasui.design/blog/7-saas-ui-design-trends-2026 (calm, command palette)
- https://uxpilot.ai/blogs/enterprise-ux-design (design system enterprise)
- https://www.w3.org/WAI/WCAG22/quickref/
