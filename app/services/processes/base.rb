# frozen_string_literal: true

module Processes
  class Base
    attr_reader :process, :performed_by, :reason, :metadata

    def initialize(process:, performed_by:, reason: nil, metadata: {})
      @process = process
      @performed_by = performed_by
      @reason = reason
      @metadata = metadata
      @errors = []
    end

    def call
      raise NotImplementedError, "Subclasses must implement #call"
    end

    def success?
      @errors.empty?
    end

    def errors
      @errors
    end

    def self.call(**args)
      new(**args).tap(&:call)
    end

    private

    def validate_authorization!(required_capability:)
      return if performed_by&.can?(required_capability)

      @errors << "Unauthorized: required capability #{required_capability}"
      raise PermissionError, @errors.first
    end

    def validate_state!(allowed_states:)
      return if allowed_states.include?(process.state_code)

      @errors << "Invalid state: #{process.state_code}, expected one of #{allowed_states.join(', ')}"
      raise StateError, @errors.first
    end

    def validate_state_transition!(from_state:, to_state:, action_code:)
      transition = ProcessStateTransition.find_by(
        from_state: ProcessState.find_by(code: from_state),
        to_state: ProcessState.find_by(code: to_state),
        action_code: action_code
      )

      return if transition&.active?

      @errors << "Invalid transition: #{from_state} → #{to_state} (#{action_code})"
      raise TransitionError, @errors.first
    end

    def validate_scope!(organization:)
      return if performed_by.organizations.pluck(:id).include?(organization.id)

      @errors << "Out of scope: user not in organization #{organization.id}"
      raise ScopeError, @errors.first
    end

    def validate_required_field!(field:, value:)
      return unless value.blank?

      @errors << "Missing required field: #{field}"
      raise ValidationError, @errors.first
    end

    def create_audit_event!(action:, entity_type: "Process", entity_id: process.id, before_data: nil, after_data: nil)
      ProcessAuditEvent.create!(
        process: process,
        actor: performed_by,
        action: action,
        entity_type: entity_type,
        entity_id: entity_id,
        before_data: before_data,
        after_data: after_data,
        ip_address: nil,
        user_agent: nil
      )
    end

    def create_transition_record!(from_state:, to_state:, action_code:)
      ProcessTransition.create!(
        process: process,
        from_state: ProcessState.find_by(code: from_state),
        to_state: ProcessState.find_by(code: to_state),
        action_code: action_code,
        performed_by: performed_by,
        organization: performed_by&.current_organization,
        reason: reason,
        notes: metadata[:notes]
      )
    end

    class Error < StandardError; end
    class PermissionError < Error; end
    class StateError < Error; end
    class TransitionError < Error; end
    class ScopeError < Error; end
    class ValidationError < Error; end
  end
end
