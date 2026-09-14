class ProcessMovement < ApplicationRecord
  self.table_name = "process_movements"

  belongs_to :process, class_name: "Sip::Process"
  belongs_to :from_organization, class_name: "Organization", optional: true
  belongs_to :to_organization, class_name: "Organization", optional: true
  belongs_to :from_user, class_name: "User", optional: true
  belongs_to :to_user, class_name: "User", optional: true
  belongs_to :performed_by, class_name: "User"

  scope :by_created_at, -> { order(created_at: :desc) }
end
