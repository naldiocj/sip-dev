# frozen_string_literal: true

module Processes
  class Receive < Base
    def call
      validate_authorization!(required_capability: "PROCESSO_VIEW")
      validate_state!(allowed_states: %w[DEVOLVIDO])

      before_data = { state: process.state_code }

      ActiveRecord::Base.transaction do
        process.update!(
          updated_by: performed_by,
          process_state_id: ProcessState.find_by(code: "DISTRIBUIDO")&.id
        )

        create_transition_record!(
          from_state: "DEVOLVIDO",
          to_state: "DISTRIBUIDO",
          action_code: "RECEBER_DEVOLUCAO"
        )

        create_audit_event!(
          action: "PROCESSO_RECEBIDO",
          before_data: before_data,
          after_data: { state: "DISTRIBUIDO" }
        )
      end

      process.reload
    rescue => e
      @errors << e.message
      raise
    end
  end
end
