# frozen_string_literal: true

module Processes
  class Suspend < Base
    def call
      validate_authorization!(required_capability: "PROCESSO_UPDATE")
      validate_state!(allowed_states: %w[EM_INSTRUCAO])
      validate_required_field!(field: "reason", value: reason)

      before_data = { state: process.state_code, reason: reason }

      ActiveRecord::Base.transaction do
        process.update!(
          updated_by: performed_by,
          process_state_id: ProcessState.find_by(code: "SUSPENSO")&.id
        )

        create_transition_record!(
          from_state: "EM_INSTRUCAO",
          to_state: "SUSPENSO",
          action_code: "SUSPENDER"
        )

        suspend_deadlines!

        create_audit_event!(
          action: "PROCESSO_SUSPENSO",
          before_data: before_data,
          after_data: { state: "SUSPENSO" }
        )
      end

      process.reload
    rescue => e
      @errors << e.message
      raise
    end

    private

    def suspend_deadlines!
      process.process_deadlines.where(status: "EM_CURSO").find_each do |deadline|
        DeadlineSuspension.create!(
          process_deadline: deadline,
          started_at: Time.current,
          reason: reason,
          created_by: performed_by
        )
        deadline.update!(status: "SUSPENSO")
      end
    end
  end
end
