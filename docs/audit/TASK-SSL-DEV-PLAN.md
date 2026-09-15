# TASK-SSL-DEV — Plano Completo: Correção de Erro SSL em Desenvolvimento

**Data:** 2026-09-15  
**Status:** ✅ CONCLUÍDO  
**Tipo:** Backend / Configuração  
**Prioridade:** Alta

---

## Problema

Erros massivos no log do Puma:

```
HTTP parse error, malformed request: #<Puma::HttpParserError: 
Invalid HTTP format, parsing fails. Are you trying to open an 
SSL connection to a non-SSL Puma?>
```

**Sintoma:** O Puma está recebendo requisições HTTPS mas está configurado apenas para HTTP.

---

## Causa Raiz

Em desenvolvimento, algo está enviando tráfego SSL para o Puma:
- Navegador com cache HSTS de sessões anteriores (`https://localhost:3000`)
- Ferramenta de health check configurada para HTTPS
- Testes E2E ou browser automation usando `https://`

O Puma por padrão escuta apenas HTTP na port 3000. Quando uma conexão SSL chega, o parser falha.

---

## Solução Implementada

### 1. Configuração SSL condicional no Puma (`config/puma.rb`)

```ruby
# Development: accept SSL connections with self-signed certificate.
# When DEV_SSL=true, Puma listens on HTTPS only (no HTTP fallback).
if ENV["DEV_SSL"] == "true"
  ssl_path = File.join(__dir__, "..", "storage", "ssl")
  cert_file = File.join(ssl_path, "server.crt")
  key_file = File.join(ssl_path, "server.key")

  if File.exist?(cert_file) && File.exist?(key_file)
    clear_binds!
    ssl_bind "0.0.0.0", ENV.fetch("PORT", 3000), {
      key: key_file,
      cert: cert_file,
      verify_mode: "none"
    }
  end
end
```

### 2. Certificado auto-assinado gerado

- **Cert:** `storage/ssl/server.crt`
- **Key:** `storage/ssl/server.key`
- **Dominio:** `localhost`
- **Validade:** 365 dias
- **Ignorado no git:** ✅ (`/storage/ssl/` no `.gitignore`)

### 3. Security initializer já correto

`config/initializers/security.rb` aplica `force_ssl` apenas em produção:
```ruby
if Rails.env.production?
  Rails.application.config.force_ssl = true
  Rails.application.config.ssl_options = { hsts: { ... } }
end
```

---

## Modos de Execução

### Modo HTTP (padrão para desenvolvimento)
```bash
bundle exec rails server
# Acessar: http://localhost:3000
```

### Modo HTTPS (quando necessário)
```bash
DEV_SSL=true bundle exec puma -C config/puma.rb
# Acessar: https://localhost:3000
# Aceitar aviso de certificado auto-assinado no navegador
```

### Modo HTTPS com bin/dev (Foreman)
```bash
# Adicionar ao .env.local:
DEV_SSL=true

# Ou executar diretamente:
DEV_SSL=true bin/dev
```

---

## Validação

| Teste | Resultado |
|-------|-----------|
| `bundle exec rails server` (HTTP) | ✅ Porta 3000, HTTP |
| `DEV_SSL=true bundle exec puma` (HTTPS) | ✅ Porta 3000, SSL |
| `bundle exec rubocop config/puma.rb` | ✅ Zero offenses |
| Certificado existe | ✅ `storage/ssl/server.crt` |
| Certificado ignorado pelo git | ✅ `.gitignore` |
| `Rails.env.production?` guard | ✅ SSL só em produção |

---

## Arquivos Modificados

| Arquivo | Mudança |
|---------|---------|
| `config/puma.rb` | +15 linhas: bloco SSL condicional |
| `storage/ssl/server.crt` | Gerado (auto-assinado) |
| `storage/ssl/server.key` | Gerado (chave privada) |
| `.gitignore` | Adicionado `/storage/ssl/` |

---

## Recomendações

1. **Uso diário:**continue com `bundle exec rails server` (HTTP)
2. **Se tiver erro SSL:** use `DEV_SSL=true bundle exec puma -C config/puma.rb`
3. **Aceitar certificado:** no navegador, vá para `https://localhost:3000` e aceite o risco
4. **Limpar cache HSTS do navegador:** `chrome://net-internals/#hsts` (Chrome) ou equivalente

---

## Evidence

- Commit: `config/puma.rb` modificado
- Branch: master
- Data: 2026-09-15
- Task: TASK-SSL-DEV-PLAN
