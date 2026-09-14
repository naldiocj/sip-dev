# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Process State Machine', type: :service do
  let(:performed_by) { create(:user, :admin) }
  let(:process) { create(:process) }

  describe 'valid transitions' do
    it 'allows REGISTADO → EM_DISTRIBUICAO' do
      # This would be handled by the Distribute service
      expect(ProcessStateTransition.can_transition?('REGISTADO', 'EM_DISTRIBUICAO', 'DISTRIBUIR')).to be true
    end

    it 'allows EM_DISTRIBUICAO → DISTRIBUIDO' do
      expect(ProcessStateTransition.can_transition?('EM_DISTRIBUICAO', 'DISTRIBUIDO', 'CONFIRMAR_DISTRIBUICAO')).to be true
    end

    it 'allows DISTRIBUIDO → EM_INSTRUCAO' do
      expect(ProcessStateTransition.can_transition?('DISTRIBUIDO', 'EM_INSTRUCAO', 'INICIAR_INSTRUCAO')).to be true
    end

    it 'allows EM_INSTRUCAO → SUSPENSO' do
      expect(ProcessStateTransition.can_transition?('EM_INSTRUCAO', 'SUSPENSO', 'SUSPENDER')).to be true
    end

    it 'allows SUSPENSO → EM_INSTRUCAO' do
      expect(ProcessStateTransition.can_transition?('SUSPENSO', 'EM_INSTRUCAO', 'RETOMAR')).to be true
    end

    it 'allows EM_INSTRUCAO → CONCLUIDO' do
      expect(ProcessStateTransition.can_transition?('EM_INSTRUCAO', 'CONCLUIDO', 'CONCLUIR')).to be true
    end

    it 'allows CONCLUIDO → ENCERRADO' do
      expect(ProcessStateTransition.can_transition?('CONCLUIDO', 'ENCERRADO', 'ENCERRAR')).to be true
    end

    it 'allows ENCERRADO → ARQUIVADO' do
      expect(ProcessStateTransition.can_transition?('ENCERRADO', 'ARQUIVADO', 'ARQUIVAR')).to be true
    end

    it 'allows ENCERRADO → REGISTADO (reopen)' do
      expect(ProcessStateTransition.can_transition?('ENCERRADO', 'REGISTADO', 'REABRIR')).to be true
    end

    it 'allows EM_INSTRUCAO → DEVOLVIDO' do
      expect(ProcessStateTransition.can_transition?('EM_INSTRUCAO', 'DEVOLVIDO', 'DEVOLVER')).to be true
    end

    it 'allows DEVOLVIDO → DISTRIBUIDO' do
      expect(ProcessStateTransition.can_transition?('DEVOLVIDO', 'DISTRIBUIDO', 'RECEBER_DEVOLUCAO')).to be true
    end
  end

  describe 'invalid transitions' do
    it 'does not allow REGISTADO → CONCLUIDO directly' do
      expect(ProcessStateTransition.can_transition?('REGISTADO', 'CONCLUIDO', 'CONCLUIR')).to be false
    end

    it 'does not allow EM_INSTRUCAO → ARQUIVADO directly' do
      expect(ProcessStateTransition.can_transition?('EM_INSTRUCAO', 'ARQUIVADO', 'ARQUIVAR')).to be false
    end

    it 'does not allow REGISTADO → ENCERRADO directly' do
      expect(ProcessStateTransition.can_transition?('REGISTADO', 'ENCERRADO', 'ENCERRAR')).to be false
    end
  end

  describe 'terminal states' do
    it 'identifies ARQUIVADO as terminal' do
      state = ProcessState.find_by(code: 'ARQUIVADO')
      expect(state.terminal).to be true
    end

    it 'identifies ENCERRADO as terminal' do
      state = ProcessState.find_by(code: 'ENCERRADO')
      expect(state.terminal).to be true
    end

    it 'identifies EM_INSTRUCAO as non-terminal' do
      state = ProcessState.find_by(code: 'EM_INSTRUCAO')
      expect(state.terminal).to be false
    end
  end

  describe 'allowed transitions from state' do
    it 'returns transitions from REGISTADO' do
      transitions = ProcessStateTransition.allowed_transitions_from('REGISTADO')
      expect(transitions.pluck(:action_code)).to include('DISTRIBUIR')
    end

    it 'returns transitions from EM_INSTRUCAO' do
      transitions = ProcessStateTransition.allowed_transitions_from('EM_INSTRUCAO')
      expect(transitions.pluck(:action_code)).to include('SUSPENDER', 'CONCLUIR', 'DEVOLVER')
    end
  end
end
