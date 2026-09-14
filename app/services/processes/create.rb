# frozen_string_literal: true

module Processes
  class Create < Base
    attr_reader :attributes

    def initialize(attributes:, performed_by:, **kwargs)
      @attributes = attributes
      super(process: nil, performed_by: performed_by, **kwargs)
    end

    def call
      validate_authorization!(required_capability: "PROCESSO_CREATE")

      ActiveRecord::Base.transaction do
        @process = Sip::Process.create!(@attributes.merge!(
          created_by: performed_by,
          updated_by: performed_by,
          data_entrada: @attributes[:data_entrada] || Time.current,
          data_registo: Time.current,
          process_state_id: ProcessState.find_by(code: "REGISTADO")&.id
        ))

        create_location!
        create_transition_record!(
          from_state: nil,
          to_state: "REGISTADO",
          action_code: "CREATE"
        )
        create_audit_event!(action: "PROCESSO_CRIADO")
      end

      @process
    rescue => e
      @errors << e.message
      raise
    end

    private

    def create_location!
      ProcessLocation.create!(
        process: @process,
        organization: performed_by.current_organization,
        user: performed_by,
        started_at: Time.current,
        created_by: performed_by,
        reason: "Registo inicial do processo"
      )
    end
  end
end
