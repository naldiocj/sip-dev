# frozen_string_literal: true

# db/seeds/05_process_types.rb
# Tipos de processo do SIP — referências para criação de processos

def seed_process_types
  return if ProcessType.count.positive?

  types = [
    { code: 'AUTO',         name: 'Auto',                 description: 'Processo iniciado de ofício pelo SIC' },
    { code: 'DENUNCIA',     name: 'Denúncia',             description: 'Processo baseado em denúncia recebida' },
    { code: 'PARTICIPACAO', name: 'Participação',       description: 'Processo baseado em participação cidadã' },
    { code: 'MANDADO_PGR',  name: 'Mandado PGR/MP',      description: 'Processo originado no Ministério Público' },
    { code: 'REQUISITORIA', name: 'Requisitoria',       description: 'Processo por requisitoria de outra entidade' },
    { code: 'TRANSPORTE',   name: 'Transporte',          description: 'Processo de transporte de materiais perigosos' }
  ]

  types.each do |t|
    ProcessType.find_or_create_by!(code: t[:code]) do |pt|
      pt.name = t[:name]
      pt.description = t[:description]
    end
  end

  puts "  [OK] #{ProcessType.count} tipos de processo criados"
end
