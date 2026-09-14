# frozen_string_literal: true

# db/seeds.rb
# Ponto de entrada principal para seed do SIP.
#
# Execução:
#   bin/rails db:seed              # executa tudo
#   RAILS_ENV=test bin/rails db:seed  # seed em teste
#
# Todos os seeds são idempotentes — seguro rodar múltiplas vezes.

require_relative 'seeds/01_capabilities'
require_relative 'seeds/02_profiles'
require_relative 'seeds/03_organizations'
require_relative 'seeds/04_users'
require_relative 'seeds/05_process_types'
require_relative 'seeds/06_diligence_types'
require_relative 'seeds/07_process_reference_data'

puts "\n=== SIP Seed — #{Rails.env} ==="
puts "Data: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\n"

seed_capabilities
seed_profiles
seed_organizations
seed_users
seed_process_types
seed_diligence_types
seed_process_reference_data

puts "\n✓ Seed concluído com sucesso"
puts "  Perfis: #{Profile.count}"
puts "  Capacidades: #{Capability.count}"
puts "  Organizações: #{Organization.count}"
puts "  Utilizadores: #{User.count}"
puts "  Tipos Processo: #{ProcessType.count}"
puts "  Tipos Diligência: #{DiligenceType.count}"
puts "  Estados Processo: #{ProcessState.count}"
puts "  Tipos Parte: #{PartyType.count}"
puts "  Naturezas Processo: #{ProcessNature.count}"
puts "  Origens Processo: #{ProcessOrigin.count}"
puts "  Prioridades Processo: #{ProcessPriority.count}"
puts "  Níveis Sigilo: #{ConfidentialityLevel.count}\n"
