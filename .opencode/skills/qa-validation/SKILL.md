---
name: qa-validation
description: >
  Valida funcionalidades através de evidências reais, prioriza Playwright E2E.
  Fluxo DISCOVER→PLAN→TEST→OBSERVE→FIX→RETEST→EVIDENCE.
---

# qa-validation

## Objetivo
Validar funcionalidades através de evidências reais, não apenas pela existência de testes.

## Fluxo
DISCOVER → PLAN → TEST → OBSERVE → FIX → RETEST → EVIDENCE

Primeiro identifica:
- testes unitários
- integration tests
- E2E
- Playwright
- fixtures
- test database
- seed
- test credentials
- scripts existentes

Para funcionalidades de UI ou fluxo de utilizador, prioriza Playwright E2E.

Não considera uma funcionalidade concluída apenas porque:
- o build passou
- TypeScript passou
- unit tests passaram
- o endpoint existe

Quando apropriado, valida o fluxo real:
login → navegação → ação → API → database → resposta → UI

Ao encontrar falha:
- reproduz
- identifica a causa
- corrige
- executa novamente
- verifica regressões

## Saída
Registra evidências em: `.ai/evidence/qa.md`

Inclui:
- cenário
- comando
- resultado
- falha
- correção
- reteste
- estado final

Nunca declara PASS sem evidência.

## Workflow
1. `glob` tests, e2e, playwright.config
2. `bos_validate gates=[test, e2e]`
3. Playwright quando aplicável
