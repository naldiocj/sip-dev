# frozen_string_literal: true

module Processes
  class Redistribute < Base
    attr_reader :new_organization, :new_user

    def initialize(process:, new_organization:, new_user: nil, performed_by:, reason: nil, metadata: {})
      @new_organization = new_organization
      @new_user = new_user
      super(process: process, performed_by: performed_by, reason: reason, metadata: metadata)
    end

    def call
      validate_authorization!(required_capability: "PROCESSO_DISTRIBUTE")
      validate_state!(allowed_states: %w[DISTRIBUIDO EM_INSTRUCAO PENDENTE])
      validate_scope!(organization: @new_organization)

      before_data = {
        state: process.state_code,
        organization_id: process.organizacao_id,
        responsible_id: process.responsavel_id
      }

      ActiveRecord::Base.transaction do
        close_previous_assignment!

        process.update!(
          organizacao_id: @new_organization.id,
          responsavel_id: @new_user&.id,
          updated_by: performed_by
        )

        create_assignment!
        create_movement!(
          from_organization: process.organizacao,
          to_organization: @new_organization,
          from_user: process.responsavel,
          to_user: @new_user
        )
        create_location!
        create_transition_record!(
          from_state: before_data[:state],
          to_state: process.state_code,
          action_code: "REDISTRIBUIR"
        )
        create_audit_event!(
          action: "PROCESSO_REDISTRIBUIDO",
          before_data: before_data,
          after_data: { state: process.state_code, organization_id: @new_organization.id }
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
        assigned_to_user: @new_user || performed_by,
        assigned_to_organization: @new_organization,
        assignment_type: "REDISTRIBUICAO",
        assigned_by: performed_by,
        started_at: Time.current,
        reason: reason
      )
    end

    def create_movement!(from_organization:, to_organization:, from_user:, to_user:)
      ProcessMovement.create!(
        process: process,
        movement_type: "REDISTRIBUICAO",
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
        organization: @new_organization,
        user: @new_user,
        started_at: Time.current,
        created_by: performed_by,
        reason: reason
      )
    end
  end
end
