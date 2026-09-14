# frozen_string_literal: true

module Processes
  class Conclude < Base
    def call
      validate_authorization!(required_capability: "PROCESSO_ENCERRAR")
      validate_state!(allowed_states: %w[EM_INSTRUCAO])
      validate_required_field!(field: "reason", value: reason)

      before_data = { state: process.state_code, reason: reason }

      ActiveRecord::Base.transaction do
        process.update!(
          updated_by: performed_by,
          process_state_id: ProcessState.find_by(code: "CONCLUIDO")&.id
        )

        create_transition_record!(
          from_state: "EM_INSTRUCAO",
          to_state: "CONCLUIDO",
          action_code: "CONCLUIR"
        )

        create_audit_event!(
          action: "PROCESSO_CONCLUIDO",
          before_data: before_data,
          after_data: { state: "CONCLUIDO" }
        )
      end

      process.reload
    rescue => e
      @errors << e.message
      raise
    end
  end
end
