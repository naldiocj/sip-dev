class ProcessDeadline < ApplicationRecord
  self.table_name = "process_deadlines"

  belongs_to :process, class_name: "Sip::Process"
  belongs_to :created_by, class_name: "User"

  scope :em_curso, -> { where(status: "EM_CURSO") }
  scope :by_due_at, -> { order(due_at: :asc) }
end
