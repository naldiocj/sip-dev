# frozen_string_literal: true

# db/seeds/07_process_reference_data.rb
# Dados de referência para o módulo de Processos

def seed_process_reference_data
  # ── Process States ──
  states = [
    { code: 'REGISTADO', name: 'Registado', description: 'Processo registado no sistema', terminal: false },
    { code: 'EM_DISTRIBUICAO', name: 'Em Distribuição', description: 'Processo em fase de distribuição', terminal: false },
    { code: 'DISTRIBUIDO', name: 'Distribuído', description: 'Processo distribuído a unidade/instrutor', terminal: false },
    { code: 'EM_INSTRUCAO', name: 'Em Instrução', description: 'Processo em fase de instrução', terminal: false },
    { code: 'DEVOLVIDO', name: 'Devolvido', description: 'Processo devolvido à origem', terminal: false },
    { code: 'PENDENTE', name: 'Pendente', description: 'Aguardando ação de terceiros', terminal: false },
    { code: 'SUSPENSO', name: 'Suspenso', description: 'Processo suspenso temporariamente', terminal: false },
    { code: 'CONCLUIDO', name: 'Concluído', description: 'Instrução concluída, aguardando decisão', terminal: false },
    { code: 'ENCERRADO', name: 'Encerrado', description: 'Processo encerrado', terminal: true },
    { code: 'ARQUIVADO', name: 'Arquivado', description: 'Processo arquivado', terminal: true },
    { code: 'ANULADO', name: 'Anulado', description: 'Processo anulado', terminal: true }
  ]

  states.each do |s|
    ProcessState.create!(code: s[:code], name: s[:name], description: s[:description], terminal: s[:terminal], active: true)
  end
  puts "  [OK] #{ProcessState.count} estados de processo"

  # ── Party Types ──
  party_types = [
    { code: 'DENUNCIANTE', name: 'Denunciante', description: 'quem denuncia o facto criminoso' },
    { code: 'PARTICIPANTE', name: 'Participante', description: 'testemunha ou participante nos factos' },
    { code: 'OFENDIDO', name: 'Ofendido', description: 'pessoa diretamente lesada pelo crime' },
    { code: 'VITIMA', name: 'Vítima', description: 'pessoa vítima do crime' },
    { code: 'ARGUIDO', name: 'Arguido', description: 'pessoa contra quem incide investigação' },
    { code: 'TESTEMUNHA', name: 'Testemunha', description: 'testemunha do caso' },
    { code: 'DECLARANTE', name: 'Declaraante', description: 'pessoa que presta declarações' },
    { code: 'QUEIXOSO', name: 'Queixoso', description: 'quem apresenta queixa' },
    { code: 'REPRESENTANTE', name: 'Representante', description: 'representante legal' },
    { code: 'MANDATARIO', name: 'Mandatário', description: 'mandatário/advogado' },
    { code: 'PERITO', name: 'Perito', description: 'perito nomeado pelo tribunal' },
    { code: 'OUTRO', name: 'Outro', description: 'outro tipo de parte' }
  ]

  party_types.each do |pt|
    PartyType.create!(code: pt[:code], name: pt[:name], description: pt[:description])
  end
  puts "  [OK] #{PartyType.count} tipos de parte"

  # ── Process State Transitions ──
  transitions = [
    { from: 'REGISTADO', to: 'EM_DISTRIBUICAO', action: 'DISTRIBUIR', requires_destination: true, requires_responsible: true },
    { from: 'EM_DISTRIBUICAO', to: 'DISTRIBUIDO', action: 'CONFIRMAR_DISTRIBUICAO', requires_responsible: true },
    { from: 'DISTRIBUIDO', to: 'EM_INSTRUCAO', action: 'INICIAR_INSTRUCAO', requires_responsible: true },
    { from: 'EM_INSTRUCAO', to: 'PENDENTE', action: 'COLOCAR_PENDENTE', requires_reason: true },
    { from: 'PENDENTE', to: 'EM_INSTRUCAO', action: 'RETOMAR_INSTRUCAO' },
    { from: 'EM_INSTRUCAO', to: 'DEVOLVIDO', action: 'DEVOLVER', requires_destination: true, requires_reason: true },
    { from: 'EM_INSTRUCAO', to: 'SUSPENSO', action: 'SUSPENDER', requires_reason: true },
    { from: 'SUSPENSO', to: 'EM_INSTRUCAO', action: 'RETOMAR' },
    { from: 'EM_INSTRUCAO', to: 'CONCLUIDO', action: 'CONCLUIR', requires_reason: true },
    { from: 'CONCLUIDO', to: 'ENCERRADO', action: 'ENCERRAR' },
    { from: 'ENCERRADO', to: 'ARQUIVADO', action: 'ARQUIVAR' },
    { from: 'ENCERRADO', to: 'REGISTADO', action: 'REABRIR', requires_reason: true },
    { from: 'DEVOLVIDO', to: 'DISTRIBUIDO', action: 'RECEBER_DEVOLUCAO' }
  ]

  transition_count = 0
  transitions.each do |t|
    from_state = ProcessState.find_by(code: t[:from])
    to_state = ProcessState.find_by(code: t[:to])
    next unless from_state && to_state

    ProcessStateTransition.create!(
      from_state: from_state,
      to_state: to_state,
      action_code: t[:action],
      description: "#{t[:from]} → #{t[:to]}: #{t[:action]}",
      requires_reason: t[:requires_reason] || false,
      requires_destination: t[:requires_destination] || false,
      requires_responsible: t[:requires_responsible] || false,
      active: true
    )
    transition_count += 1
  end
  puts "  [OK] #{transition_count} transições de estado"

  # ── Process Natures ──
  process_natures = [
    { code: 'COMUM', name: 'Comum', description: 'Crime comum' },
    { code: 'ORGANIZADO', name: 'Crime Organizado', description: 'Crime organizado' },
    { code: 'TERRORISMO', name: 'Terrorismo', description: 'Crime de terrorismo' },
    { code: 'CORRUPCAO', name: 'Corrupção', description: 'Crime de corrupção' },
    { code: 'BRANQUEAMENTO', name: 'Branqueamento de Capitais', description: 'Branqueamento de capitais' },
    { code: 'NARCOTRAFICO', name: 'Narcotráfico', description: 'Tráfico de drogas' },
    { code: 'CIBERNETICO', name: 'Crime Cibernético', description: 'Crime informático' },
    { code: 'TRAFICO_ENXUBIDO', name: 'Tráfico de Seres Humanos', description: 'Tráfico de seres humanos' }
  ]

  process_natures.each do |pn|
    ProcessNature.create!(code: pn[:code], name: pn[:name], description: pn[:description])
  end
  puts "  [OK] #{ProcessNature.count} naturezas de processo"

  # ── Process Origins ──
  process_origins = [
    { code: 'PIQUETE', name: 'Piquete', description: 'Registado no piquete' },
    { code: 'SECRETARIA', name: 'Secretaria', description: 'Registado na secretaria' },
    { code: 'PGR_MP', name: 'PGR/MP', description: 'Originado no Ministério Público' },
    { code: 'OUTRA_ENTIDADE', name: 'Outra Entidade', description: 'Recebido de outra entidade' },
    { code: 'REQUERIMENTO', name: 'Requerimento', description: 'Requerimento de cidadão' }
  ]

  process_origins.each do |po|
    ProcessOrigin.create!(code: po[:code], name: po[:name], description: po[:description])
  end
  puts "  [OK] #{ProcessOrigin.count} origens de processo"

  # ── Process Priorities ──
  process_priorities = [
    { code: 'NORMAL', name: 'Normal', description: 'Processo com prioridade normal' },
    { code: 'ALTA', name: 'Alta', description: 'Processo com prioridade alta' },
    { code: 'URGENTE', name: 'Urgente', description: 'Processo urgente' }
  ]

  process_priorities.each do |pp|
    ProcessPriority.create!(code: pp[:code], name: pp[:name], description: pp[:description])
  end
  puts "  [OK] #{ProcessPriority.count} prioridades"

  # ── Confidentiality Levels ──
  confidentiality_levels = [
    { code: 'PUBLICO', name: 'Público', description: 'Acesso público' },
    { code: 'INTERNO', name: 'Interno', description: 'Acesso interno ao SIC' },
    { code: 'CONFIDENCIAL', name: 'Confidencial', description: 'Acesso restrito' },
    { code: 'SECRETO', name: 'Secreto', description: 'Informação reservada' },
    { code: 'SIGILOSO', name: 'Sigiloso', description: 'Sigilo absoluto' }
  ]

  confidentiality_levels.each do |cl|
    ConfidentialityLevel.create!(code: cl[:code], name: cl[:name], description: cl[:description])
  end
  puts "  [OK] #{ConfidentialityLevel.count} níveis de confidencialidade"
end
