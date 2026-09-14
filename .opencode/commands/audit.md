---
name: audit
description: "Run a full governance audit of the current session state, permissions, and evidence."
agent: orchestrator
template: |
  Execute uma auditoria completa do estado atual do Behavior OS:
  
  1. Liste todas as sessões ativas e seu estado
  2. Verifique permissões configuradas vs usadas
  3. Revise evidências de operações R3+
  4. Identifique políticas violadas ou quase violadas
  5. Gere relatório de compliance
  
  Use o agente @governance para coleta de evidências.
---
