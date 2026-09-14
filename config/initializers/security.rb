# frozen_string_literal: true

# Security Headers - using Rails built-in configuration
Rails.application.config.action_dispatch.default_headers.merge!(
  'X-Content-Type-Options' => 'nosniff',
  'X-Frame-Options' => 'DENY',
  'X-XSS-Protection' => '1; mode=block',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
)

# Force SSL only in production AND when explicitly requested via FORCE_SSL env var.
# This prevents "SSL connection to non-SSL Puma" errors when running behind
# a reverse proxy that terminates TLS (nginx, Caddy, etc.) OR when FORCE_SSL=true.
if Rails.env.production? && ENV.fetch("FORCE_SSL", "false") == "true"
  Rails.application.config.force_ssl = true
  Rails.application.config.ssl_options = { hsts: { expires: 1.year, include_subdomains: true, preload: true } }
end
