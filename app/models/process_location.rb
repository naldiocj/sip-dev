class ProcessLocation < ApplicationRecord
  self.table_name = "process_locations"

  belongs_to :process, class_name: "Sip::Process"
  belongs_to :organization
  belongs_to :user, optional: true
  belongs_to :created_by, class_name: "User"

  scope :by_started_at, -> { order(started_at: :desc) }
end
