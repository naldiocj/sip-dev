# frozen_string_literal: true

# Security Headers - using Rails built-in configuration
Rails.application.config.action_dispatch.default_headers.merge!(
  'X-Content-Type-Options' => 'nosniff',
  'X-Frame-Options' => 'DENY',
  'X-XSS-Protection' => '1; mode=block',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
)

# Force SSL only in production environment
if Rails.env.production?
  Rails.application.config.force_ssl = true
  Rails.application.config.ssl_options = { hsts: { expires: 1.year, include_subdomains: true, preload: true } }
end
