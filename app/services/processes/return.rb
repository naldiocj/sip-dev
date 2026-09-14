# frozen_string_literal: true

module Processes
  class Return < Base
    attr_reader :destination_organization

    def initialize(process:, destination_organization:, performed_by:, reason: nil, metadata: {})
      @destination_organization = destination_organization
      super(process: process, performed_by: performed_by, reason: reason, metadata: metadata)
    end

    def call
      validate_authorization!(required_capability: "PROCESSO_DEVOLVER")
      validate_state!(allowed_states: %w[EM_INSTRUCAO PENDENTE])
      validate_required_field!(field: "reason", value: reason)
      validate_scope!(organization: @destination_organization)

      before_data = {
        state: process.state_code,
        organization_id: process.organizacao_id,
        responsible_id: process.responsavel_id,
        reason: reason
      }

      ActiveRecord::Base.transaction do
        close_previous_assignment!

        process.update!(
          organizacao_id: @destination_organization.id,
          responsavel_id: nil,
          updated_by: performed_by,
          process_state_id: ProcessState.find_by(code: "DEVOLVIDO")&.id
        )

        create_assignment!
        create_movement!
        create_location!
        create_transition_record!(
          from_state: before_data[:state],
          to_state: "DEVOLVIDO",
          action_code: "DEVOLVER"
        )
        create_audit_event!(
          action: "PROCESSO_DEVOLVIDO",
          before_data: before_data,
          after_data: { state: "DEVOLVIDO", organization_id: @destination_organization.id }
        )
      end

      process.reload
    rescue => e
      @errors << e.message
      raise
    end

    private

    def close_previous_assignment!
      assignment = process.process_assignments.where("ended_at IS NULL OR ended_at > ?", Time.current).order(:started_at).last
      return unless assignment
      assignment.update!(ended_at: Time.current)
    end

    def create_assignment!
      ProcessAssignment.create!(
        process: process,
        assigned_to_user: performed_by,
        assigned_to_organization: @destination_organization,
        assignment_type: "DEVOLUCAO",
        assigned_by: performed_by,
        started_at: Time.current,
        reason: reason
      )
    end

    def create_movement!
      ProcessMovement.create!(
        process: process,
        movement_type: "DEVOLUCAO",
        from_organization: process.organizacao,
        to_organization: @destination_organization,
        from_user: process.responsavel,
        to_user: performed_by,
        performed_by: performed_by,
        reason: reason,
        notes: metadata[:notes]
      )
    end

    def create_location!
      ProcessLocation.create!(
        process: process,
        organization: @destination_organization,
        user: performed_by,
        started_at: Time.current,
        created_by: performed_by,
        reason: reason
      )
    end
  end
end
