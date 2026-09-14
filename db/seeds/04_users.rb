# frozen_string_literal: true

# db/seeds/04_users.rb
# Utilizadores e contas de autenticação
#
# Sempre que possível, recuperar dados existentes em vez de recriar.
# Senhas geradas localmente — nunca armazenadas em código-fonte.

def seed_users
  # ── Director Geral (acesso institucional máximo) ──
  return if User.exists?(username: 'director')

  direcao_geral = Profile.find_by(code: 'DIRECAO_GERAL')
  root_org = Organization.find_by(code: 'ROOT')

  raise 'DIRECAO_GERAL profile not found' unless direcao_geral
  raise 'ROOT organization not found' unless root_org

  user = User.create!(
    email: 'director@sic.gov.ao',
    username: 'director',
    password: ENV.fetch('SIP_ADMIN_PASSWORD', 'Sic@2024Angola'),
    password_confirmation: ENV.fetch('SIP_ADMIN_PASSWORD', 'Sic@2024Angola'),
    first_name: 'Director',
    last_name: 'Geral',
    organization_id: root_org.id,
    status: 'active'
  )

  UserAssignment.create!(
    user: user,
    organization: root_org,
    profile: direcao_geral,
    role: 'director_geral',
    started_at: Time.current
  )

  Account.find_or_create_by!(login: 'director') do |account|
    account.email = user.email
    account.password_hash = BCrypt::Password.create(
      ENV.fetch('SIP_ADMIN_PASSWORD', 'Sic@2024Angola'), cost: 4
    )
    account.verified_at = Time.current
  end

  puts "  [OK] Admin criado: #{user.email}"
end
