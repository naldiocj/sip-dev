class ProcessClosure < ApplicationRecord
  self.table_name = "process_closures"

  belongs_to :process, class_name: "Sip::Process"
  belongs_to :closed_by, class_name: "User"
end
