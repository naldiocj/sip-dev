# frozen_string_literal: true

# Security Headers
Rails.application.configure do
  config.middleware.insert_before 0, Rack::SecurityHeaders do |config|
    config.content_security_policy do |policy|
      policy.default_src :self, :https
      policy.font_src    :self, :https, :data
      policy.img_src     :self, :https, :data
      policy.object_src  :none
      policy.script_src  :self, :https
      policy.style_src   :self, :https, :unsafe_inline
      policy.connect_src :self, :https
    end

    config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
    config.content_security_policy_report_only = false
    config.referrer_policy = :strict_origin_when_cross_origin
    config.permit_cross_domain_polices = false
  end
end

# HSTS
Rails.application.config.force_ssl = true
Rails.application.config.ssl_options = { hsts: { expires: 1.year, include_subdomains: true, preload: true } }

# XSS Protection
Rails.application.config.action_dispatch.default_headers.merge!(
  'X-Content-Type-Options' => 'nosniff',
  'X-Frame-Options' => 'DENY',
  'X-XSS-Protection' => '1; mode=block',
  'X-Permitted-Cross-Domain-Policies' => 'none',
  'Cross-Origin-Opener-Policy' => 'same-origin',
  'Cross-Origin-Embedder-Policy' => 'require-corp'
)
