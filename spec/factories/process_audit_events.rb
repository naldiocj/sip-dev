# frozen_string_literal: true

FactoryBot.define do
  factory :process_audit_event do
    action { "PROCESSO_CRIADO" }
    entity_type { "Process" }
    
    process { create(:process) }
    actor { create(:user) }
  end
end
