---
name: official-docs-grounding
description: >
  Garante decisões fundamentadas em documentação oficial atual e compatível com a versão.
  Usa Context7/webfetch antes de implementar APIs.
---

# official-docs-grounding

## Objetivo
Garantir que decisões técnicas sejam fundamentadas em documentação oficial atual e compatível com a versão do projeto.

Antes de implementar APIs, configurações ou padrões específicos de uma tecnologia:
- identifica a tecnologia
- identifica a versão
- localiza a documentação oficial
- verifica a API/padrão
- confirma compatibilidade
- somente depois permite implementação

## Prioridade das fontes
1. documentação oficial da tecnologia
2. documentação oficial da versão
3. changelog/migration guide oficial
4. código fonte oficial
5. fontes secundárias somente quando necessário

Não utilizar blogs, Stack Overflow, snippets aleatórios ou documentação antiga como autoridade principal quando existir documentação oficial.

Quando existir Context7 ou outro mecanismo de documentação disponível no ambiente, utilizar a fonte correspondente antes da implementação.

## Saída
Registrar evidências em: `.ai/evidence/docs-grounding.md`

Para cada decisão importante registrar:
- tecnologia
- versão
- documentação consultada
- decisão
- motivo
- eventual incompatibilidade encontrada

Se não for possível verificar uma informação crítica, marcar como UNKNOWN e não inventar.

## Workflow
1. `bos_truth tech=<tech> check=api`
2. `context7` ou `webfetch` na doc oficial
3. Registrar em `.ai/evidence/docs-grounding.md`
