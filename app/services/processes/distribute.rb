# frozen_string_literal: true

module Processes
  class Distribute < Base
    attr_reader :destination_organization, :destination_user

    def initialize(process:, destination_organization:, destination_user: nil, performed_by:, reason: nil, metadata: {})
      @destination_organization = destination_organization
      @destination_user = destination_user
      super(process: process, performed_by: performed_by, reason: reason, metadata: metadata)
    end

    def call
      validate_authorization!(required_capability: "PROCESSO_DISTRIBUTE")
      validate_state!(allowed_states: %w[REGISTADO EM_DISTRIBUICAO])
      validate_scope!(organization: @destination_organization)

      before_data = {
        state: process.state_code,
        organization_id: process.organizacao_id,
        responsible_id: process.responsavel_id
      }

      ActiveRecord::Base.transaction do
        # Close previous assignment if exists
        close_previous_assignment!

        # Create new assignment
        create_assignment!

        # Create movement
        create_movement!(
          from_organization: process.organizacao,
          to_organization: @destination_organization,
          from_user: process.responsavel,
          to_user: @destination_user
        )

        # Create location
        create_location!

        # Update process state
        process.update!(
          organizacao_id: @destination_organization.id,
          responsavel_id: @destination_user&.id,
          updated_by: performed_by,
          process_state_id: ProcessState.find_by(code: "DISTRIBUIDO")&.id
        )

        # Record transition
        create_transition_record!(
          from_state: before_data[:state],
          to_state: "DISTRIBUIDO",
          action_code: "DISTRIBUIR"
        )

        # Audit
        after_data = {
          state: "DISTRIBUIDO",
          organization_id: @destination_organization.id,
          responsible_id: @destination_user&.id
        }
        create_audit_event!(
          action: "PROCESSO_DISTRIBUIDO",
          before_data: before_data,
          after_data: after_data
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
        assigned_to_user: @destination_user || performed_by,
        assigned_to_organization: @destination_organization,
        assignment_type: "DISTRIBUICAO",
        assigned_by: performed_by,
        started_at: Time.current,
        reason: reason
      )
    end

    def create_movement!(from_organization:, to_organization:, from_user:, to_user:)
      ProcessMovement.create!(
        process: process,
        movement_type: "DISTRIBUICAO",
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
        user: @destination_user,
        started_at: Time.current,
        created_by: performed_by,
        reason: reason
      )
    end
  end
end
