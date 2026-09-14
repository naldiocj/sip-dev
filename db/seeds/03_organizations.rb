# frozen_string_literal: true

# db/seeds/03_organizations.rb
# Estrutura organizacional do SIC Angola — nível nacional
#
# Hierarquia:
#   ROOT → DIRECÇÃO-GERAL → DIRECÇÃO
#                                  ├── PIQUETE    (irmão do departamento)
#                                  └── DEPARTAMENTO → SECÇÃO
#
# Nenhuma organização com código existente será sobrescrita.

def seed_organizations
  return if Organization.where(code: 'ROOT').exists?

  # Mapa: code → { name, level, parent_code }
  orgs = [
    # Raiz institucional
    { code: 'ROOT',           name: 'Serviço de Investigação Criminal',            level: 'root',            parent: nil },
    { code: 'DG',             name: 'Direcção-Geral',                              level: 'direccao_geral',  parent: 'ROOT' },

    # Cada direcção com piquete e departamento→secção
    { code: '01',             name: 'Direcção de Investigação de Acidentes',       level: 'direccao',        parent: 'DG' },
    { code: '01-PIQ',         name: 'Piquete de Investigação de Acidentes',        level: 'piquete',         parent: '01' },
    { code: '01-DPT',         name: 'Departamento de Investigação de Acidentes',   level: 'departamento',    parent: '01' },
    { code: '01-SEC',         name: 'Secção de Investigação de Acidentes I',       level: 'seccao',          parent: '01-DPT' },

    { code: '02',             name: 'Direcção de Combate aos Crimes Contra as Pessoas', level: 'direccao',  parent: 'DG' },
    { code: '02-PIQ',         name: 'Piquete de Combate a Crimes Contra as Pessoas', level: 'piquete',     parent: '02' },
    { code: '02-DPT',         name: 'Departamento de Combate a Crimes Contra as Pessoas', level: 'departamento', parent: '02' },
    { code: '02-SEC',         name: 'Secção de Crimes Contra as Pessoas I',        level: 'seccao',        parent: '02-DPT' },

    { code: '03',             name: 'Direcção de Combate aos Crimes Contra o Património', level: 'direccao', parent: 'DG' },
    { code: '03-PIQ',         name: 'Piquete de Combate a Crimes Patrimoniais',    level: 'piquete',         parent: '03' },
    { code: '03-DPT',         name: 'Departamento de Combate a Crimes Patrimoniais', level: 'departamento', parent: '03' },
    { code: '03-SEC',         name: 'Secção de Crimes Patrimoniais I',             level: 'seccao',          parent: '03-DPT' },

    { code: '04',             name: 'Direcção de Combate aos Crimes Financeiros e Fiscais', level: 'direccao', parent: 'DG' },
    { code: '04-PIQ',         name: 'Piquete de Crimes Financeiros e Fiscais',     level: 'piquete',         parent: '04' },
    { code: '04-DPT',         name: 'Departamento de Crimes Financeiros e Fiscais', level: 'departamento', parent: '04' },
    { code: '04-SEC',         name: 'Secção de Crimes Económicos I',               level: 'seccao',          parent: '04-DPT' },

    { code: '05',             name: 'Direcção de Combate ao Crime Organizado',     level: 'direccao',        parent: 'DG' },
    { code: '05-PIQ',         name: 'Piquete de Crime Organizado',                 level: 'piquete',         parent: '05' },
    { code: '05-DPT',         name: 'Departamento de Crime Organizado',            level: 'departamento',    parent: '05' },
    { code: '05-SEC',         name: 'Secção de Crime Organizado I',                level: 'seccao',          parent: '05-DPT' },

    { code: '06',             name: 'Direcção Central de Operações',               level: 'direccao',        parent: 'DG' },
    { code: '06-PIQ',         name: 'Piquete Central de Operações',                level: 'piquete',         parent: '06' },
    { code: '06-DPT',         name: 'Departamento Central de Operações',           level: 'departamento',    parent: '06' },
    { code: '06-SEC',         name: 'Secção Operacional I',                        level: 'seccao',          parent: '06-DPT' },

    { code: '07',             name: 'Direcção de Combate ao Narcotráfico',         level: 'direccao',        parent: 'DG' },
    { code: '07-PIQ',         name: 'Piquete de Combate ao Narcotráfico',          level: 'piquete',         parent: '07' },
    { code: '07-DPT',         name: 'Departamento de Combate ao Narcotráfico',     level: 'departamento',    parent: '07' },
    { code: '07-SEC',         name: 'Secção de Narcotráfico I',                    level: 'seccao',          parent: '07-DPT' },

    { code: '08',             name: 'Direcção de Combate ao Tráfico de Pedras, Metais Preciosos e Crimes Contra o Ambiente', level: 'direccao', parent: 'DG' },
    { code: '08-PIQ',         name: 'Piquete de Tráfico de Pedras e Metais Preciosos', level: 'piquete',  parent: '08' },
    { code: '08-DPT',         name: 'Departamento de Tráfico de Pedras e Metais Preciosos', level: 'departamento', parent: '08' },
    { code: '08-SEC',         name: 'Secção de Crimes Ambientais I',             level: 'seccao',          parent: '08-DPT' },

    { code: '09',             name: 'Direcção de Combate ao Crime Contra a Economia e Saúde Pública', level: 'direccao', parent: 'DG' },
    { code: '09-PIQ',         name: 'Piquete de Crimes contra Economia e Saúde Pública', level: 'piquete', parent: '09' },
    { code: '09-DPT',         name: 'Departamento de Crimes contra Economia e Saúde Pública', level: 'departamento', parent: '09' },
    { code: '09-SEC',         name: 'Secção de Saúde Pública I',                 level: 'seccao',          parent: '09-DPT' },

    { code: '10',             name: 'Direcção de Atendimento ao Menor em Conflito com a Lei', level: 'direccao', parent: 'DG' },
    { code: '10-PIQ',         name: 'Piquete de Atendimento ao Menor',             level: 'piquete',         parent: '10' },
    { code: '10-DPT',         name: 'Departamento de Atendimento ao Menor',        level: 'departamento',    parent: '10' },
    { code: '10-SEC',         name: 'Secção do Menor I',                          level: 'seccao',          parent: '10-DPT' },

    { code: '11',             name: 'Direcção de Combate ao Crime Cibernético',    level: 'direccao',        parent: 'DG' },
    { code: '11-PIQ',         name: 'Piquete de Crime Cibernético',                level: 'piquete',         parent: '11' },
    { code: '11-DPT',         name: 'Departamento de Crime Cibernético',           level: 'departamento',    parent: '11' },
    { code: '11-SEC',         name: 'Secção de Ciberinvestigação I',               level: 'seccao',          parent: '11-DPT' },

    { code: '12',             name: 'Direcção de Combate ao Crime de Corrupção',   level: 'direccao',        parent: 'DG' },
    { code: '12-PIQ',         name: 'Piquete de Combate à Corrupção',              level: 'piquete',         parent: '12' },
    { code: '12-DPT',         name: 'Departamento de Combate à Corrupção',         level: 'departamento',    parent: '12' },
    { code: '12-SEC',         name: 'Secção de Corrupção I',                       level: 'seccao',          parent: '12-DPT' }
  ]

  org_map = {}

  orgs.each do |org_data|
    parent = org_data[:parent] ? org_map[org_data[:parent]] : nil
    org = Organization.create!(
      name: org_data[:name],
      code: org_data[:code],
      level: org_data[:level],
      parent_id: parent&.id,
      description: "#{org_data[:code]} — #{org_data[:name]}"
    )
    org_map[org_data[:code]] = org
  end

  direccoes = Organization.where(level: 'direccao').count
  departamentos = Organization.where(level: 'departamento').count
  seccoes = Organization.where(level: 'seccao').count
  piquetes = Organization.where(level: 'piquete').count

  puts "  [OK] #{Organization.count} organizações criadas"
  puts "       Direções: #{direccoes} | Departamentos: #{departamentos} | Secções: #{seccoes} | Piquetes: #{piquetes}"
end
