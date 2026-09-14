# Regras adicionais de governança
# Estas regras complementam o AGENTS.md

## Regra R-001: Proteção de arquivos sensíveis
- Arquivos com padrão `*.env`, `*.env.*`, `.env.local` são SEMPRE deny em read
- Variáveis de ambiente não podem ser logadas em evidence

## Regra R-002: Controle de operações git
- `git push --force` é sempre deny
- `git push` requer ask (aprovação manual)
- `git push --dry-run` é allow
- `git reset --hard` é deny

## Regra R-003: Separação de papéis
- Architect não pode executar edits
- Governance não pode executar bash
- QA não pode editar código
- Somente orchestrator pode delegar para outros agentes

## Regra R-004: Loop detection
- Após 3 repetições idênticas de mesma tool call → ask
- Agente deve variar abordagem após doom_loop trigger
- Loop infinito é treat como R4

## Regra R-005: External directory
- Todo acesso fora do worktree requer external_directory allow
- Caminhos absolutos fora do projeto são ask por padrão
- Home directory (~) é permitido para leitura

## Regra R-006: Evidence obrigatória
- Operações R3+ devem ter evidence registrada
- Evidence deve incluir: operação, agente, risco, decisão, timestamp
- Evidence é imutável após registro

## Regra R-007: Transições de estado
- Transições inválidas são bloqueadas
- Estado só avança após evidence ser registrada
- Denial não permite progressão até reclassificação

## Regra R-008: Runtime pnpm-first
- `pnpm *`, `bun *`, `pnpm dlx *`, `pnpm exec *` são ALLOW
- `node *` direto é ASK (preferir `pnpm exec` / `pnpm dlx`)
- `npm *` e `npx *` são ASK (preferir `pnpm`)
- `python *` e `python3 *` são DENY
- Violação R-008 gera ASK/DENY conforme acima e é registrada em evidence
