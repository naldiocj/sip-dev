---
name: tailwind-v4
description: >
  Tailwind CSS v4 — CSS-first, @theme, @tailwindcss/postcss.
  Source: https://tailwindcss.com/docs. Pnpm-first.
---

# tailwind-v4

> Tech: tailwindcss@latest | Generated: 2026-09-10

## Install (pnpm-first)
```bash
pnpm add -D tailwindcss@latest @tailwindcss/postcss@latest
```

## Config v4 (sem tailwind.config.js)
```css
/* src/app/globals.css */
@import "tailwindcss";
@theme { --color-primary: oklch(0.5 0.2 240); --radius: 0.5rem; }
```
```js
// postcss.config.mjs
export default { plugins: { "@tailwindcss/postcss": {} } }
```

## Workflow
1. bos_discover
2. bos_truth tech=tailwind
3. Implement
