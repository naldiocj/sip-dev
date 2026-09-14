class ProcessReopening < ApplicationRecord
  self.table_name = "process_reopenings"

  belongs_to :process, class_name: "Sip::Process"
  belongs_to :reopened_by, class_name: "User"
end
