class ProcessAssignment < ApplicationRecord
  self.table_name = "process_assignments"

  belongs_to :process, class_name: "Sip::Process"
  belongs_to :assigned_to_user, class_name: "User"
  belongs_to :assigned_to_organization, class_name: "Organization"
  belongs_to :assigned_by, class_name: "User"

  scope :active, -> { where("ended_at IS NULL OR ended_at > ?", Time.current) }
  scope :by_started_at, -> { order(started_at: :desc) }
end
