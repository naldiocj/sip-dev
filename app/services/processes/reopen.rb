# frozen_string_literal: true

module Processes
  class Reopen < Base
    def call
      validate_authorization!(required_capability: "PROCESSO_CREATE")
      validate_state!(allowed_states: %w[ENCERRADO ARQUIVADO])
      validate_required_field!(field: "reason", value: reason)

      before_data = { state: process.state_code }

      ActiveRecord::Base.transaction do
        process.update!(
          updated_by: performed_by,
          process_state_id: ProcessState.find_by(code: "REGISTADO")&.id
        )

        ProcessReopening.create!(
          process: process,
          reopened_at: Time.current,
          reopened_by: performed_by,
          legal_basis: metadata[:legal_basis],
          reason: reason,
          notes: metadata[:notes]
        )

        create_transition_record!(
          from_state: before_data[:state],
          to_state: "REGISTADO",
          action_code: "REABRIR"
        )

        create_audit_event!(
          action: "PROCESSO_REABERTO",
          before_data: before_data,
          after_data: { state: "REGISTADO" }
        )
      end

      process.reload
    rescue => e
      @errors << e.message
      raise
    end
  end
end
