---
name: typescript-strict
description: >
  Impede degradação de type safety. Proíbe any, casts escondidos, @ts-ignore sem justificativa.
---

# typescript-strict

## Objetivo
Impedir degradação de type safety em projetos TypeScript.

## Regras
- Não utilizar any explícito
- Não utilizar as any
- Não utilizar casts para esconder erros
- Não utilizar @ts-ignore sem justificativa documentada
- Não utilizar @ts-expect-error sem comentário explicando o motivo
- Não transformar tipos desconhecidos em any
- Preferir: unknown, type guards, generics, discriminated unions, schema validation, Zod, tipos inferidos, utility types

Antes de criar um novo tipo:
- procura tipos existentes
- procura schemas existentes
- procura contratos existentes
- reutiliza-os quando apropriado

Depois da implementação executar os checks disponíveis:
- typecheck
- lint
- testes

Se encontrar any, classifica:
- existente e fora do escopo
- introduzido pela alteração
- necessário por limitação externa
- possível de eliminar

A skill não deve simplesmente substituir any por unknown sem verificar o fluxo de tipos.

Objetivo final: type safety real, não apenas ausência textual da palavra any.

## Workflow
1. `grep` any no diff
2. `bos_validate gates=[type, lint]`
3. Classificar e corrigir
