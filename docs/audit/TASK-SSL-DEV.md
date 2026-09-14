# TASK-SSL-DEV — Correção de SSL em Ambiente de Desenvolvimento

**Data:** 2026-09-15  
**Status:** ✅ CONCLUÍDO  
**Tipo:** Backend / Configuração  
**Prioridade:** Alta

---

## Problema

Erros massivos de parsing HTTP no log do Puma:

```
HTTP parse error, malformed request: #<Puma::HttpParserError: 
Invalid HTTP format, parsing fails. Are you trying to open an SSL 
connection to a non-SSL Puma?>
```

**Sintoma:** O servidor Puma recebia requisições HTTPS mas estava configurado apenas para HTTP.

---

## Causa Raiz

Arquivo `config/initializers/security.rb` aplicava `force_ssl = true` em **todos os ambientes**, não apenas produção:

```ruby
# ERRADO - aplicava em todos os ambientes
Rails.application.config.force_ssl = true
Rails.application.config.ssl_options = { hsts: { expires: 1.year, include_subdomains: true, preload: true } }
```

O comentário no código dizia "Force SSL in production" mas a implementação não respeitava isso.

---

## Solução Aplicada

Adicionar condição `if Rails.env.production?` para aplicar SSL apenas em produção:

```diff
- # Force SSL in production
- Rails.application.config.force_ssl = true
- Rails.application.config.ssl_options = { hsts: { expires: 1.year, include_subdomains: true, preload: true } }
+ # Force SSL only in production environment
+ if Rails.env.production?
+   Rails.application.config.force_ssl = true
+   Rails.application.config.ssl_options = { hsts: { expires: 1.year, include_subdomains: true, preload: true } }
+ end
```

---

## Validação

| Teste | Resultado |
|-------|-----------|
| `Rails.env` | `development` ✅ |
| `force_ssl` config | `false` ✅ (era `true`) |
| Servidor response | HTTP 200 ✅ |
| Puma escutando | `tcp://localhost:3000` ✅ |

---

## Por que esta é a correção correta?

1. **Desenvolvimento não precisa de SSL** — localhost é ambiente seguro
2. **Performance** — SSL adiciona overhead desnecessário em dev
3. **Simplicidade** — não requer certificados auto-assinados ou configuração extra
4. **Produção protegida** — SSL permanece forçado em produção onde é necessário
5. **HSTS adequado** — políticas de segurança forte só em produção

---

## Lições Aprendidas

1. **Comentários enganosos** — o comentário dizia "production" mas o código não respeitava
2. **Initializers globais** — configurações em `config/initializers/` afetam todos os ambientes
3. **Verificação essencial** — sempre validar `Rails.env` antes de aplicar configs sensíveis

---

## Recomendações para o Futuro

1. **Environment-specific configs** — considerar mover configs de SSL para `config/environments/production.rb`
2. **Linter/Security scan** — adicionar verificação para configs que afetam todos os ambientes
3. **Documentação** — documentar em `CONTRIBUTING.md` que initializers são globais

---

## Evidence

- Commit: `80fa0e2`
- Branch: `master`
- Data: `2026-09-15`
- Arquivo modificado: `config/initializers/security.rb`
