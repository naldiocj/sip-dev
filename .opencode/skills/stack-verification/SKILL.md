---
name: stack-verification
description: >
  Impede uso de APIs incompatíveis com versões reais.
  Descobre versões via package.json, lockfile, runtime e registra em .ai/evidence/stack.md.
---

# stack-verification

## Objetivo
Impedir que agentes utilizem APIs, padrões ou documentação incompatíveis com as versões reais do projeto.

## Fluxo obrigatório
DISCOVER → DETECT → VERIFY → LOAD DOCS → RECORD

Descobre as versões reais através de:
- package.json
- lockfile
- workspace configuration
- runtime
- CLI version
- configs
- código existente

Nunca assumes que a versão instalada é a versão mais recente.

## Saída
Cria ou atualiza: `.ai/evidence/stack.md`

Registra:
- linguagem
- runtime
- framework
- ORM
- database
- auth
- UI
- build tool
- package manager
- testing
- lint/format
- infrastructure
- versões exatas

Para cada tecnologia importante, identifica:
- versão instalada
- versão declarada
- versão efetivamente utilizada
- documentação correspondente
- APIs permitidas
- APIs deprecated
- breaking changes relevantes

Se houver conflito entre documentação encontrada e versão instalada:
- identifica o conflito
- não escolhe arbitrariamente
- verifica documentação oficial correspondente à versão
- registra a decisão

## Regra crítica
NUNCA implementar baseado apenas em memória do modelo quando a API depende da versão.

Reutilizável em qualquer stack.

## Workflow
1. `read` package.json, pnpm-workspace.yaml, turbo.json
2. `bash` pnpm --version, node --version
3. `bos_truth` para cada tech
4. Gerar `.ai/evidence/stack.md`
