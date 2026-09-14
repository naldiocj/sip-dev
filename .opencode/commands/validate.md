---
name: validate
description: "Run validation gates (typecheck, lint, tests) and return PASS/FAIL for each."
agent: orchestrator
template: |
  Execute validação completa dos gates de qualidade:
  
  1. TypeGate — verificar tipos TypeScript (tsc --noEmit)
  2. LintGate — verificar lint (biome check)
  3. TestGate — verificar testes (bun test)
  4. EvidenceGate — verificar evidências registradas
  
  Use a tool bos_validate com gates: ["type", "lint", "test", "evidence"]
  
  Resultado esperado: objeto com campo "valid" (true/false) e lista de resultados por gate.
  
  Se algum gate falhar, reportar:
  - Nome do gate
  - Razão da falha
  - Recomendação de correção
