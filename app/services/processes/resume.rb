# frozen_string_literal: true

module Processes
  class Resume < Base
    def call
      validate_authorization!(required_capability: "PROCESSO_UPDATE")
      validate_state!(allowed_states: %w[SUSPENSO])

      before_data = { state: process.state_code }

      ActiveRecord::Base.transaction do
        process.update!(
          updated_by: performed_by,
          process_state_id: ProcessState.find_by(code: "EM_INSTRUCAO")&.id
        )

        resume_deadlines!

        create_transition_record!(
          from_state: "SUSPENSO",
          to_state: "EM_INSTRUCAO",
          action_code: "RETOMAR"
        )

        create_audit_event!(
          action: "PROCESSO_RETOMADO",
          before_data: before_data,
          after_data: { state: "EM_INSTRUCAO" }
        )
      end

      process.reload
    rescue => e
      @errors << e.message
      raise
    end

    private

    def resume_deadlines!
      process.process_deadlines.where(status: "SUSPENSO").find_each do |deadline|
        suspension = deadline.deadline_suspensions.order(:created_at).last
        suspension&.update!(ended_at: Time.current)
        deadline.update!(status: "EM_CURSO")
      end
    end
  end
end
