---
name: safe-implementation
description: >
  Garante que o agente não comece a programar antes de compreender o contexto.
  Fluxo UNDERSTAND→DISCOVER→VERIFY→PLAN→IMPLEMENT→TEST→AUDIT→EVIDENCE.
---

# safe-implementation

## Objetivo
Garantir que o agente não comece a programar antes de compreender o contexto necessário.

## Fluxo obrigatório
UNDERSTAND → DISCOVER → VERIFY → PLAN → IMPLEMENT → TEST → AUDIT → EVIDENCE

Antes de editar:
- identifica objetivo
- identifica arquivos relevantes
- identifica dependências
- verifica contratos existentes
- verifica padrões do projeto
- verifica versões
- consulta documentação quando necessário
- cria um plano pequeno

Durante implementação:
- faz alterações pequenas
- preserva contratos existentes
- evita duplicação
- reutiliza abstrações existentes
- não cria abstrações prematuras
- não altera arquivos não relacionados sem motivo
- não ignora erros de typecheck/lint/testes

Depois:
- typecheck
- lint
- unit/integration tests relevantes
- Playwright quando aplicável
- audit
- evidence

Se uma decisão crítica não puder ser comprovada, para a implementação daquela parte e registra BLOCKED ou UNKNOWN.

Nunca declara sucesso apenas porque o código foi escrito.

## Workflow
1. `architecture-discovery` skill
2. `stack-verification` skill
3. `official-docs-grounding` se precisar de API
4. `plan` + `implement` pequeno
5. `qa-validation` + `security-review`
