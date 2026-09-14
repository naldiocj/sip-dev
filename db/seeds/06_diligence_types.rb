# frozen_string_literal: true

# db/seeds/06_diligence_types.rb
# Tipos de diligência do SIP

def seed_diligence_types
  return if DiligenceType.count.positive?

  types = [
    { code: 'OUVIDORIA',     name: 'Ouvidoria',            description: 'Oitiva de testemunhas e intervenientes' },
    { code: 'BUSCA_CASA',    name: 'Busca e Apreensão',     description: 'Busca em habitação e instalações' },
    { code: 'BUSCA_PESSOA',  name: 'Busca Corporal',        description: 'Busca corporal a pessoa' },
    { code: 'PERICIA',       name: 'Perícia',               description: 'Exame técnico/pericial' },
    { code: 'IDENTIFICACAO', name: 'Identificação',         description: 'Identificação criminal' },
    { code: 'INTERCEPTACAO', name: 'Interceptação',         description: 'Interceptação telefónica e digital' },
    { code: 'INSPECAO',      name: 'Inspeção',              description: 'Inspeção de veículos e locais' },
    { code: 'DEPOIMENTO',    name: 'Depoimento',            description: 'Colheita de depoimento' },
    { code: 'RECONHECIMENTO', name: 'Reconhecimento',       description: 'Reconhecimento de pessoa ou coisa' },
    { code: 'LOCAL_CRIME',   name: 'Reconstituição',        description: 'Reconstituição do factó' }
  ]

  types.each do |t|
    DiligenceType.find_or_create_by!(code: t[:code]) do |dt|
      dt.name = t[:name]
      dt.description = t[:description]
    end
  end

  puts "  [OK] #{DiligenceType.count} tipos de diligência criados"
end
