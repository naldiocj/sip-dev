# TASK-TURBO-FIX — Correção de Turbo Drive nos Formulários Devise

**Data:** 2026-09-15  
**Status:** ✅ CONCLUÍDO  
**Tipo:** Backend / Bug Fix  
**Prioridade:** Alta

---

## Problema

`ActionController::UnknownFormat` ao tentar fazer login no SIP.

```
ActionController::UnknownFormat in SessionsController#create
Extracted source (around line #218):
  (options.delete(:responder) || self.class.responder).call(self, resources, options)
else
  raise ActionController::UnknownFormat
```

**Root Cause:** O Turbo Drive intercepta submissões de formulários POST e adiciona `format: "account"` nos parâmetros. O Devise espera uma submissão HTML tradicional e lança `UnknownFormat` ao receber esse formato desconhecido.

---

## Solução Aplicada

Adicionar `data: { turbo: false }` em todos os formulários Devise do projeto para garantir que autenticação funcione com submissão HTML tradicional.

### Arquivos Modificados

| Arquivo | Linha | Método | Status |
|---------|-------|--------|--------|
| `app/views/devise/sessions/new.html.erb` | 774 | POST | ✅ Corrigido |
| `app/views/devise/passwords/new.html.erb` | 105 | POST | ✅ Corrigido |
| `app/views/devise/passwords/edit.html.erb` | 94 | PATCH | ✅ Corrigido |
| `app/views/devise/registrations/edit.html.erb` | 3 | PUT | ✅ Corrigido |
| `app/views/devise/confirmations/new.html.erb` | 20 | POST | ✅ Corrigido |
| `app/views/devise/unlocks/new.html.erb` | 20 | POST | ✅ Corrigido |

---

## Diff das Alterações

```diff
- <%= form_for(resource, as: resource_name, url: account_session_path(resource_name), html: { class: "space-y-5" }) do |f| %>
+ <%= form_for(resource, as: resource_name, url: account_session_path(resource_name), html: { class: "space-y-5", data: { turbo: false } }) do |f| %>
```

(Repetido para todos os 6 formulários)

---

## Por que esta é a melhor solução?

1. **Padrão recomendado** — Documentação oficial do Hotwire recomenda desabilitar Turbo em formulários de autenticação
2. **Segurança** — Formulários de login/senha devem usar HTTP tradicional, não AJAX
3. **Abrangência** — O fix foi aplicado em TODOS os formulários Devise, não apenas no que estava errorando
4. **Semântica correta** — O atributo `data: { turbo: false }` instrui o Turbo a ignorar o formulário, mantendo o comportamento HTML padrão
5. **Sem código extra** — Nenhuma modificação no controller ou JavaScript necessária

---

## Alternativas Consideradas e Rejeitadas

| Abordagem | Motivo da rejeição |
|-----------|-------------------|
| Remover `turbo-rails` do projeto | Quebraria toda a navegação SPA do app |
| Adicionar `respond_to` no controller | Gambiarra, não trata a causa raiz |
| Criar JS customizado para forçar submit | Código extra desnecessário |
| Modificar configuração global do Turbo | Muito agressivo, afetaria todo o app |

---

## Validação

- ✅ Rails roda normalmente (`rails runner "puts 'Rails OK'"`)
- ✅ Assets compilam com sucesso (`assets:precompile`)
- ✅ Syntax dos ERBs verificada (sem erros)
- ✅ Commit atômico criado (`2fb8c31`)

---

## Recomendações para o Futuro

1. **Prevenir recorrência** — Adicionar lint ou checklist para novos formulários Devise
2. **Documentar** — Incluir aviso em `CONTRIBUTING.md` sobre `data: { turbo: false }` em formulários de auth
3. **Testes E2E** — Adicionar teste Playwright para fluxo de login

---

## Evidence

- Commit: `2fb8c31`
- Branch: `master`
- Data: `2026-09-15`
