# frozen_string_literal: true

module Processes
  class Close < Base
    def call
      validate_authorization!(required_capability: "PROCESSO_ENCERRAR")
      validate_state!(allowed_states: %w[CONCLUIDO])

      before_data = { state: process.state_code }

      ActiveRecord::Base.transaction do
        process.update!(
          updated_by: performed_by,
          process_state_id: ProcessState.find_by(code: "ENCERRADO")&.id
        )

        ProcessClosure.create!(
          process: process,
          closure_type: "NORMAL",
          closed_at: Time.current,
          closed_by: performed_by,
          reason: reason,
          notes: metadata[:notes]
        )

        create_transition_record!(
          from_state: "CONCLUIDO",
          to_state: "ENCERRADO",
          action_code: "ENCERRAR"
        )

        create_audit_event!(
          action: "PROCESSO_ENCERRADO",
          before_data: before_data,
          after_data: { state: "ENCERRADO" }
        )
      end

      process.reload
    rescue => e
      @errors << e.message
      raise
    end
  end
end
