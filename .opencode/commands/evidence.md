---
name: evidence
description: "Show evidence log for current mission or generated report."
agent: governance
template: |
  Gere relatório de evidências:
  
  1. Ler .behavior-os/evidence/evidence.json
  2. Agrupar por missão (missionId)
  3. Mostrar:
     - Total de evidências
     - Por agente
     - Por nível de risco
     - Últimas 10 entradas
  
  Formato tabela: Operacao | Agente | Risco | Decisao | Timestamp
