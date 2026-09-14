class ProcessAuditEvent < ApplicationRecord
  self.table_name = "process_audit_events"

  belongs_to :process, class_name: "Sip::Process"
  belongs_to :actor, class_name: "User"

  scope :by_created_at, -> { order(created_at: :desc) }
end
