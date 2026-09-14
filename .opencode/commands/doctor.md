---
name: doctor
description: "Check Behavior OS health: versions, sources, DNA valid, permissions valid."
agent: orchestrator
template: |
  Execute verificação de saúde do Behavior OS:
  
  1. Detectar stack com bos_discover
  2. Verificar versões com bos_truth para cada componente
  3. Validar DNA YAMLs em .behavior-os/dna/
  4. Verificar permissões em opencode.json
  5. Verificar se plugin está carregado
  6. Verificar se skills estão disponíveis
  
  Resultado: STATUS: READY ou STATUS: ISSUES com lista de problemas
