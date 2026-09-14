---
name: risk
description: "Assess the risk level of a pending operation before execution."
agent: orchestrator
template: |
  Avalie o risco da seguinte operação:
  
  $ARGUMENTS
  
  Classifique usando:
  - R1 (allow): leitura segura
  - R2 (allow): edição local
  - R3 (ask): operação com efeito colateral
  - R4 (deny): operação crítica ou irreversível
  
  Considere: tipo de arquivo, comando, contexto, histórico.
---
