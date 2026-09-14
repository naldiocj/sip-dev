# frozen_string_literal: true

module Processes
  class TakeOver < Base
    attr_reader :target_organization

    def initialize(process:, target_organization:, performed_by:, reason: nil, metadata: {})
      @target_organization = target_organization
      super(process: process, performed_by: performed_by, reason: reason, metadata: metadata)
    end

    def call
      validate_authorization!(required_capability: "PROCESSO_DISTRIBUTE")
      validate_state!(allowed_states: %w[DISTRIBUIDO EM_INSTRUCAO PENDENTE])
      validate_scope!(organization: @target_organization)

      before_data = {
        state: process.state_code,
        organization_id: process.organizacao_id,
        responsible_id: process.responsavel_id
      }

      ActiveRecord::Base.transaction do
        close_previous_assignment!

        process.update!(
          organizacao_id: @target_organization.id,
          responsavel_id: performed_by.id,
          updated_by: performed_by,
          process_state_id: ProcessState.find_by(code: "EM_INSTRUCAO")&.id
        )

        create_assignment!
        create_movement!(
          from_organization: process.organizacao,
          to_organization: @target_organization,
          from_user: process.responsavel,
          to_user: performed_by
        )
        create_location!
        create_transition_record!(
          from_state: before_data[:state],
          to_state: "EM_INSTRUCAO",
          action_code: "AVOCAR"
        )
        create_audit_event!(
          action: "PROCESSO_AVOCADO",
          before_data: before_data,
          after_data: { state: "EM_INSTRUCAO", organization_id: @target_organization.id }
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
        assigned_to_organization: @target_organization,
        assignment_type: "AVOCACAO",
        assigned_by: performed_by,
        started_at: Time.current,
        reason: reason
      )
    end

    def create_movement!(from_organization:, to_organization:, from_user:, to_user:)
      ProcessMovement.create!(
        process: process,
        movement_type: "AVOCACAO",
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
        organization: @target_organization,
        user: performed_by,
        started_at: Time.current,
        created_by: performed_by,
        reason: reason
      )
    end
  end
end
