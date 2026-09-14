---
name: evidence-and-truth
description: >
  Separa fatos comprovados de suposições. Classifica FACT/INFERENCE/UNKNOWN/RISK/DECISION/BLOCKED.
  Produz .ai/evidence/evidence.json e .ai/evidence/<task>.md
---

# evidence-and-truth

## Objetivo
Separar fatos comprovados de suposições durante o trabalho dos agentes.

Toda descoberta relevante deve ser classificada como:
- FACT
- INFERENCE
- UNKNOWN
- RISK
- DECISION
- BLOCKED

FACT exige evidência observável:
- arquivo
- linha
- configuração
- comando
- output
- teste
- documentação oficial

A skill deve impedir frases como "está funcionando" quando não existe teste ou evidência correspondente.

Para cada tarefa concluída, registrar:
- objetivo
- mudanças
- arquivos afetados
- verificações executadas
- resultados
- problemas
- decisões
- limitações
- estado final

Estados permitidos: PASS, FAIL, BLOCKED, PARTIAL

Produzir:
- `.ai/evidence/evidence.json`
- e, quando apropriado: `.ai/evidence/<task>.md`

Nunca fabricar evidências.
Nunca preencher resultados de testes que não foram executados.

## Workflow
1. Durante discovery: classificar cada finding
2. Durante execute: logar mudanças
3. `bos_evidence` com gates
4. `bos_validate` antes de DONE
