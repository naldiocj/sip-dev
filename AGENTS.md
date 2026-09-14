# Behavior OS — Governance Rules

## Princípios Fundamentais

1. **Classifique antes de agir** — toda operação passa por DISCOVER → CLASSIFY → ASSESS
2. **Registre evidências** — cada transição de estado deve ser documentada
3. **Princípio do menor privilégio** — agentes recebem apenas permissões necessárias
4. **Separação de papéis** — quem planeja não executa; quem executa não audita
5. **Recusar por padrão** — operações não classificadas são tratadas como R4 (deny)

## Classificação de Operações

### Por Tipo

| Tipo | Exemplos | Risco padrão |
|------|----------|-------------|
| Leitura | `read`, `glob`, `grep` | R1 — allow |
| Edição local | `edit`, `write` em arquivos do projeto | R2 — allow |
| Execução local | `bash` com comandos seguros | R2 — allow |
| Operação com efeito | `git push`, deploy scripts | R3 — ask |
| Operacao critica | `rm -rf`, alterar configs, modificar permissões | R4 — deny |

### Por Contexto

- **Arquivos de configuração do projeto** (`opencode.json`, `AGENTS.md`): R2
- **Arquivos de código fonte**: R2
- **Arquivos `.env` e credenciais**: R4 — deny automático
- **Diretórios externos ao projeto**: R3 — ask
- **Comandos que acessam rede**: R3 — ask

## Políticas de Segurança

### Política P1 — Proteção de Credenciais
- Arquivos `.env`, `.env.*`, `*.env.example` são deny em `read`
- Variáveis de ambiente sensíveis não podem ser logadas

### Política P2 — Contenção de Projeto
- Acesso a caminhos fora do worktree requer `external_directory` allow explícito
- Operações em `/etc`, `/root`, `~/.ssh` são deny

### Política P3 — Controle de Push
- `git push --force` é sempre deny
- `git push` requer ask (aprovação manual)
- `git push --dry-run` é allow

### Política P4 — Loops perigosos
- `doom_loop` aciona ask após 3 repetições idênticas
- Agente deve ser instruído a variar abordagem

### Política P5 — Subagentes
- Somente `orchestrator` pode lançar subagentes
- `governance` é read-only e não pode delegar
- Agentes não-governança não podem chamar `governance`

## Fluxo de Autorização

```
Operação proposta
       ↓
  DISCOVER (contexto)
       ↓
  CLASSIFY (tipo + impacto)
       ↓
  ASSESS (risco R1-R4)
       ↓
  CHECK (políticas aplicáveis)
       ↓
  AUTHORIZE
   ├── ALLOW → executar
   ├── ASK   → solicitar aprovação
   └── DENY  → rejeitar
       ↓
  EVIDENCE (registrar)
```

## Regras por Agente

### Orchestrator
- Pode editar arquivos do projeto
- Pode executar bash (com ask para operações R3)
- Pode delegar para architect, backend, frontend, qa
- Deve registrar evidência de cada handoff

### Architect
- Read-only
- Pode executar bash apenas para leitura (`git log`, `grep`, `cat`)
- Não pode delegar para outros agentes

### Backend / Frontend
- Podem editar arquivos do projeto
- Podem executar bash para testes e build
- Devem solicitar ask para git push e operações de deploy

### QA
- Read-only para código
- Pode executar testes
- Não pode fazer edições

### Governance
- Read-only total
- Pode auditar evidências
- Não executa operações no projeto

## Transições de Estado

Cada sessão Behavior OS segue:

```
IDLE → DISCOVERING → CLASSIFYING → ASSESSING → AUTHORIZED → EXECUTING → EVIDENCED → IDLE
                                    ↓
                              DENIED (fim)
                                    ↓
                              ASK_PENDING → APPROVED / REJECTED
```

## Comportamento em Caso de Violação

1. Se uma política for violada, a operação é imediatamente blocked
2. O agente deve registrar o incidente em evidence
3. Em caso de loop de recusAs repetidas, o orchestrator deve reavaliar a estratégia
4. Usuário deve ser notificado via `question` tool quando appropriado

## Integração com OpenCode

- Use `permission` config para controle granular (não `tools` booleano legado)
- Use `tool.execute.before` hook para inspeção prévia
- Use `session.idle` event para registrar conclusão
- Use `todo.updated` para rastrear progresso multi-etapa
- Use custom tools para operações Behavior OS específicas


<!-- behavior-os -->
# Behavior OS — Governança Obrigatória

**OpenCode: 1.18.30**

## Fluxo Obrigatório para Toda Operação

```
DISCOVER → CLASSIFY → TRUTH → KNOWLEDGE → PLAN → EXECUTE → VALIDATE → EVIDENCE → DONE
```

Nunca pular etapas. Se um gate falhar: FAIL → DIAGNOSE → FIX → REVALIDATE

## Classificação Rápida

| Tipo | Risco | Exemplo |
|------|-------|---------|
| Leitura (read/grep/glob) | R1 — allow | ler arquivo |
| Edição local (edit/write) | R2 — allow | modificar código |
| Bash seguro (pnpm/git status) | R2 — allow | rodar comando |
| Operação com efeito | R3 — ask | git push, deploy |
| Crítico (rm -rf, configs) | R4 — deny | destruir dados |

## Regras Hard

- `.env`, credenciais → **DENY** automático
- `git push --force`, `git reset --hard` → **DENY**
- `python` → **DENY**
- `npm`/`npx` → **ASK** (preferir `pnpm`)
- `node` direto → **ASK** (preferir `pnpm exec`)
- Architect/Governance/QA não editam código
- Somente orchestrator delega subagentes
- Evidence obrigatória para R3+

## Workflow por Agente

### Orchestrator (eu)
1. `bos_discover scope=full` — descobrir stack
2. `bos_classify` — classificar operação
3. `bos_truth` — verificar versões oficiais
4. `bos_skill` — adquirir skill se necessário
5. `skill: creator` — análise profunda antes de implementar
6. Executar com evidence no final

### Ao iniciar sessão
- Verificar estado: `bos_state`
- Se idle → rodar `bos_discover`
- Se há missão ativa → continuarEvidence

## Integração com Context7
- Context7 para docs de bibliotecas/frameworks
- Behavior OS para governança do projeto
- Bos_truth para verificar versões reais vs documentação
<!-- behavior-os -->
## Nova Regra: Commits por Task

A partir de agora, cada task concluída deve gerar um commit atomico com:
- Mensagem seguindo conventional commits: `feat: TASK-XXX - descrição`
- Todas as alterações da task num único commit
- Documentação actualizada em `docs/audit/TASK-XXX.md`

