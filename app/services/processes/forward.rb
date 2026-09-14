# frozen_string_literal: true

module Processes
  class Forward < Base
    attr_reader :destination_organization

    def initialize(process:, destination_organization:, performed_by:, reason: nil, metadata: {})
      @destination_organization = destination_organization
      super(process: process, performed_by: performed_by, reason: reason, metadata: metadata)
    end

    def call
      validate_authorization!(required_capability: "PROCESSO_DISTRIBUTE")
      validate_state!(allowed_states: %w[DISTRIBUIDO EM_INSTRUCAO])
      validate_scope!(organization: @destination_organization)

      before_data = {
        state: process.state_code,
        organization_id: process.organizacao_id
      }

      ActiveRecord::Base.transaction do
        close_previous_assignment!

        process.update!(
          organizacao_id: @destination_organization.id,
          updated_by: performed_by,
          process_state_id: ProcessState.find_by(code: "EM_DISTRIBUICAO")&.id
        )

        create_assignment!
        create_movement!(
          from_organization: process.organizacao,
          to_organization: @destination_organization,
          from_user: process.responsavel,
          to_user: nil
        )
        create_location!
        create_transition_record!(
          from_state: before_data[:state],
          to_state: "EM_DISTRIBUICAO",
          action_code: "ENCAMINHAR"
        )
        create_audit_event!(
          action: "PROCESSO_ENCAMINHADO",
          before_data: before_data,
          after_data: { state: "EM_DISTRIBUICAO", organization_id: @destination_organization.id }
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
        assignment_type: "ENCAMINHAMENTO",
        assigned_by: performed_by,
        started_at: Time.current,
        reason: reason
      )
    end

    def create_movement!(from_organization:, to_organization:, from_user:, to_user:)
      ProcessMovement.create!(
        process: process,
        movement_type: "ENCAMINHAMENTO",
        from_organization: from_organization,
        to_organization: to_organization,
        from_user: from_user,
        to_user: to_user,
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
