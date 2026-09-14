---
name: discover
description: "Discover project context: stack, versions, architecture. Must run before R2+ tasks."
agent: orchestrator
template: |
  Execute descobrimento completo do projeto:
  
  1. Usar bos_discover com scope "full"
  2. Verificar se .behavior-os/truth/project.yaml foi criado
  3. Reportar:
     - Stack detectada
     - Versões encontradas
     - Package manager
     - Framework identificado
     - Arquivos de configuração relevantes
  
  Este comando deve ser executado ANTES de qualquer tarefa R2+.
