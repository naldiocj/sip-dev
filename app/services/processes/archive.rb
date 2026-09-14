# frozen_string_literal: true

module Processes
  class Archive < Base
    def call
      validate_authorization!(required_capability: "PROCESSOs_ARCHIVE")
      validate_state!(allowed_states: %w[ENCERRADO])

      before_data = { state: process.state_code }

      ActiveRecord::Base.transaction do
        process.update!(
          updated_by: performed_by,
          process_state_id: ProcessState.find_by(code: "ARQUIVADO")&.id
        )

        create_transition_record!(
          from_state: "ENCERRADO",
          to_state: "ARQUIVADO",
          action_code: "ARQUIVAR"
        )

        create_audit_event!(
          action: "PROCESSO_ARQUIVADO",
          before_data: before_data,
          after_data: { state: "ARQUIVADO" }
        )
      end

      process.reload
    rescue => e
      @errors << e.message
      raise
    end
  end
end
