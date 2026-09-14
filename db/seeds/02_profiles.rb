# frozen_string_literal: true

# db/seeds/02_profiles.rb
# Perfis funcionais do SIP — papéis com responsabilidades delimitadas
#
# Cada perfil é um conjunto de capacidades (many-to-many via profile_capabilities).
# A separação entre PERFIL e CAPABILIDADE permite composição flexível.
#
# Princípio: cada perfil recebe apenas o necessário (menor privilégio).

def seed_profiles
  return if Profile.exists?

  profiles = {
    'ADMIN' => {
      name: 'Administrador do Sistema',
      description: 'Administração técnica e configuração global — sem acesso operacional',
      capabilities: %w[
        USER_MANAGE PROFILE_MANAGE ORGANIZATION_MANAGE
        AUDIT_VIEW SYSTEM_CONFIGURE
        PROCESSO_VIEW DOCUMENT_VIEW TRAMITACAO_VIEW
      ]
    },
    'DIRECAO_GERAL' => {
      name: 'Direcção-Geral',
      description: 'Recepção institucional, validação, encaminhamento e supervisão',
      capabilities: %w[
        PROCESSO_VIEW PROCESSO_CREATE PROCESSO_UPDATE
        PROCESSO_DISTRIBUTE PROCESSO_RETURN PROCESSO_ARCHIVE
        PROCESSO_SUBMIT
        DOCUMENT_VIEW DOCUMENT_CREATE DOCUMENT_UPDATE DOCUMENT_SIGN DOCUMENT_SUBMIT
        DILIGENCIA_CREATE DILIGENCIA_UPDATE
        MANDADO_VIEW MANDADO_CREATE
        TRAMITACAO_VIEW TRAMITACAO_CREATE
      ]
    },
    'DIRECAO' => {
      name: 'Direcção',
      description: 'Gestão, análise, supervisão e encaminhamento dos processos da Direcção',
      capabilities: %w[
        PROCESSO_VIEW PROCESSO_CREATE PROCESSO_UPDATE
        PROCESSO_DISTRIBUTE PROCESSO_RETURN PROCESSO_ASSIGN PROCESSO_SUBMIT
        DOCUMENT_VIEW DOCUMENT_CREATE DOCUMENT_UPDATE DOCUMENT_SIGN DOCUMENT_SUBMIT
        DILIGENCIA_CREATE DILIGENCIA_UPDATE DILIGENCIA_COMPLETE
        MANDADO_VIEW MANDADO_CREATE MANDADO_EXECUTE
        TRAMITACAO_VIEW TRAMITACAO_CREATE
      ]
    },
    'DEPARTAMENTO' => {
      name: 'Departamento',
      description: 'Gestão dos processos do Departamento e encaminhamento para Secção ou Instrutor',
      capabilities: %w[
        PROCESSO_VIEW PROCESSO_CREATE PROCESSO_UPDATE
        PROCESSO_DISTRIBUTE PROCESSO_RETURN PROCESSO_ASSIGN PROCESSO_SUBMIT
        DOCUMENT_VIEW DOCUMENT_CREATE DOCUMENT_UPDATE DOCUMENT_SIGN DOCUMENT_SUBMIT
        DILIGENCIA_CREATE DILIGENCIA_UPDATE DILIGENCIA_COMPLETE
        MANDADO_VIEW MANDADO_CREATE MANDADO_EXECUTE
        TRAMITACAO_VIEW TRAMITACAO_CREATE
      ]
    },
    'SECCAO' => {
      name: 'Secção',
      description: 'Gestão operacional dos processos da Secção e distribuição aos Instrutores',
      capabilities: %w[
        PROCESSO_VIEW PROCESSO_CREATE PROCESSO_UPDATE
        PROCESSO_DISTRIBUTE PROCESSO_RETURN PROCESSO_ASSIGN PROCESSO_SUBMIT
        DOCUMENT_VIEW DOCUMENT_CREATE DOCUMENT_UPDATE
        DILIGENCIA_CREATE DILIGENCIA_UPDATE
        MANDADO_VIEW MANDADO_CREATE
        TRAMITACAO_VIEW TRAMITACAO_CREATE
      ]
    },
    'INSTRUTOR' => {
      name: 'Instrutor Processual',
      description: 'Execução da instrução processual e realização dos actos atribuídos',
      capabilities: %w[
        PROCESSO_VIEW PROCESSO_UPDATE PROCESSO_SUBMIT
        DOCUMENT_VIEW DOCUMENT_CREATE DOCUMENT_UPDATE DOCUMENT_SIGN DOCUMENT_SUBMIT
        DILIGENCIA_CREATE DILIGENCIA_UPDATE DILIGENCIA_COMPLETE
        MANDADO_VIEW MANDADO_EXECUTE
        TRAMITACAO_VIEW TRAMITACAO_CREATE
      ]
    },
    'PIQUETE' => {
      name: 'Efetivo de Piquete',
      description: 'Registo e tratamento inicial de denúncias, participações e autos',
      capabilities: %w[
        PROCESSO_VIEW PROCESSO_CREATE
        DOCUMENT_VIEW DOCUMENT_CREATE
        DILIGENCIA_CREATE
        MANDADO_VIEW
        TRAMITACAO_VIEW
      ]
    },
    'PGR' => {
      name: 'Efetivo PGR/MP',
      description: 'Tratamento e acompanhamento dos processos provenientes do Ministério Público/PGR',
      capabilities: %w[
        PROCESSO_VIEW PROCESSO_CREATE PROCESSO_UPDATE
        PROCESSO_RETURN PROCESSO_SUBMIT
        DOCUMENT_VIEW DOCUMENT_CREATE DOCUMENT_UPDATE DOCUMENT_SIGN DOCUMENT_SUBMIT
        DILIGENCIA_CREATE DILIGENCIA_UPDATE DILIGENCIA_COMPLETE
        MANDADO_VIEW MANDADO_CREATE MANDADO_EXECUTE
        TRAMITACAO_VIEW TRAMITACAO_CREATE
      ]
    }
  }

  profiles.each do |code, attrs|
    profile = Profile.find_or_create_by!(code: code) do |p|
      p.name = attrs[:name]
      p.description = attrs[:description]
    end

    attrs[:capabilities].each do |cap_name|
      cap = Capability.find_by(name: cap_name)
      next unless cap
      profile.capabilities << cap unless profile.capabilities.exists?(id: cap.id)
    end

    puts "  [OK] #{code.ljust(20)} #{profile.capabilities.count.to_s.rjust(2)} capacidades"
  end
end
