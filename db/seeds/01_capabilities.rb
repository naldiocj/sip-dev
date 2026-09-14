# frozen_string_literal: true

# db/seeds/01_capabilities.rb
# Capacidades granulares do SIP — base atómica de autorização
#
# Cada capacidade representa um acto atómico.
# Perfis ganham acesso através de profile_capabilities.
#
# Nunca hard-code nomes em controllers ou models — consultar via capability.

def seed_capabilities
  return if Capability.count.positive?

  capabilities = [
    # ── Processos ──
    { name: 'PROCESSO_VIEW',            description: 'Visualizar processos no seu âmbito' },
    { name: 'PROCESSO_CREATE',          description: 'Criar novos processos' },
    { name: 'PROCESSO_UPDATE',          description: 'Atualizar dados de processos' },
    { name: 'PROCESSO_DISTRIBUTE',      description: 'Distribuir processos entre unidades' },
    { name: 'PROCESSO_RETURN',          description: 'Devolver processos à origem' },
    { name: 'PROCESSO_ASSIGN',          description: 'Atribuir processos a instrutores' },
    { name: 'PROCESSO_SUBMIT',          description: 'Submeter processos para revisão' },
    { name: 'PROCESSO_CLOSE',           description: 'Fechar processos' },
    { name: 'PROCESSO_ARCHIVE',         description: 'Arquivar processos concluídos' },

    # ── Documentos ──
    { name: 'DOCUMENT_VIEW',            description: 'Visualizar documentos' },
    { name: 'DOCUMENT_CREATE',          description: 'Criar documentos' },
    { name: 'DOCUMENT_UPDATE',          description: 'Atualizar documentos' },
    { name: 'DOCUMENT_SIGN',            description: 'Assinar documentos' },
    { name: 'DOCUMENT_SUBMIT',          description: 'Submeter documentos para apreciação' },

    # ── Diligências ──
    { name: 'DILIGENCIA_CREATE',        description: 'Criar diligências' },
    { name: 'DILIGENCIA_UPDATE',        description: 'Atualizar diligências' },
    { name: 'DILIGENCIA_COMPLETE',      description: 'Concluir diligências' },

    # ── Mandados ──
    { name: 'MANDADO_VIEW',             description: 'Visualizar mandados' },
    { name: 'MANDADO_CREATE',           description: 'Criar mandados' },
    { name: 'MANDADO_EXECUTE',          description: 'Executar mandados' },

    # ── Tramitação ──
    { name: 'TRAMITACAO_VIEW',          description: 'Visualizar tramitações' },
    { name: 'TRAMITACAO_CREATE',        description: 'Registar tramitações' },

    # ── Gestão Organizacional ──
    { name: 'USER_MANAGE',              description: 'Gerir utilizadores do sistema' },
    { name: 'PROFILE_MANAGE',           description: 'Gerir perfis e permissões' },
    { name: 'ORGANIZATION_MANAGE',      description: 'Gerir estrutura organizacional' },

    # ── Auditoria e Sistema ──
    { name: 'AUDIT_VIEW',               description: 'Consultar logs de auditoria' },
    { name: 'SYSTEM_CONFIGURE',         description: 'Configurar parâmetros do sistema' }
  ]

  capabilities.each do |cap|
    Capability.find_or_create_by!(name: cap[:name]) do |c|
      c.description = cap[:description]
    end
  end

  created = Capability.count
  puts "  [OK] #{created} capacidades criadas"
end
