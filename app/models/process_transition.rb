class ProcessTransition < ApplicationRecord
  self.table_name = "process_transitions"

  belongs_to :process, class_name: "Sip::Process"
  belongs_to :from_state, class_name: "ProcessState", optional: true
  belongs_to :to_state, class_name: "ProcessState"
  belongs_to :performed_by, class_name: "User"
  belongs_to :organization, class_name: "Organization", optional: true

  scope :by_created_at, -> { order(created_at: :desc) }
end
