# TASK-001 — Fix Puma SSL Parse Error em Desenvolvimento

## Problema

```
HTTP parse error, malformed request: #<Puma::HttpParserError: Invalid HTTP format, 
parsing fails. Are you trying to open an SSL connection to a non-SSL Puma?>
```

### Raiz do Problema

1. `config/initializers/security.rb:12-14` força SSL em production:
   ```ruby
   if Rails.env.production?
     Rails.application.config.force_ssl = true
     Rails.application.config.ssl_options = { hsts: { ... } }
   end
   ```

2. `docker-compose.yml:29` roda com `RAILS_ENV: production`

3. Não há reverse proxy com terminação SSL (não existe nginx/caddy)

4. Puma roda em HTTP plano na porta 3000

5. Clientes (health checks, browsers, ferramentas externas) tentam conexão HTTPS → TLS handshake chega como bytes brutos no Puma → erro de parse

---

## Plano de Resolução

### Opção A — Desenvolvimento sem SSL (mais simples)

**Arquivo:** `config/initializers/security.rb`

Remover `force_ssl` do bloco production, ou tornar condicional a um flag:

```ruby
# Apenas forçar SSL se EXPLICITAMENTE configurado (production real)
if Rails.env.production? && ENV.fetch("FORCE_SSL", "false") == "true"
  Rails.application.config.force_ssl = true
  Rails.application.config.ssl_options = { hsts: { expires: 1.year, include_subdomains: true, preload: true } }
end
```

**Arquivo:** `docker-compose.yml`

Adicionar variável para dev vs prod, e rodar dev com `RAILS_ENV=development`.

---

### Opção B — Adicionar Reverse Proxy com Caddy (recomendado)

**Arquivo:** `docker-compose.yml`

Adicionar serviço Caddy que faz terminação SSL e proxy reverso para Puma:

```yaml
  caddy:
    image: caddy:2-alpine
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
    depends_on:
      - sip-web
    restart: unless-stopped
```

**Novo arquivo:** `Caddyfile`
```
{
  email dev@example.com
}

:443 {
  tls internal
  reverse_proxy sip-web:3000
}
```

Manter `force_ssl = true` no production.rb.

---

### Opção C — Configurar HTTPS direto no Puma (auto-assinado)

**Arquivo:** `config/puma.rb`

Já existe suporte a SSL auto-assinado em development (linhas 44-56), mas só roda em `RAILS_ENV=development`.

Para development com SSL auto-assinado:
```bash
mkdir -p storage/ssl
openssl req -x509 -newkey rsa:2048 -keyout storage/ssl/server.key \
  -out storage/ssl/server.crt -days 365 -nodes \
  -subj "/CN=localhost"
```

Então acessar via `https://localhost:3000`.

---

## Decisão

Para desenvolvimento local, recomendo **Opção A + geração de certificado auto-assinado** (combinação A+C):

1. Remover `force_ssl` automático do security.rb (deixar sob controle via env var)
2. Gerar certificado SSL auto-assinado para development
3. Docker compose de dev usar `RAILS_ENV=development`

Para produção real, manter `force_ssl` ativo e usar Caddy/nginx como proxy.

---

## Arquivos a Modificar

| Arquivo | Alteração |
|---------|-----------|
| `config/initializers/security.rb` | Tornar force_ssl condicional a ENV |
| `docker-compose.yml` | Adicionar variável de ambiente RAILS_ENV controlável |
| `script/generate-ssl-cert` | Script auxiliar para gerar cert auto-assinado |
| `Procfile.dev` | Atualizar se necessário |

---

## Verificação

Após mudanças:
1. `docker compose up` → confirmar que health check passa sem erro SSL
2. `curl -k https://localhost:3000/up` → retornar 200
3. `curl http://localhost:3000/up` → retornar 200 (se não estiver forçando SSL)
