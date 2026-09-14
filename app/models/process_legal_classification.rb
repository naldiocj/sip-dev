class ProcessLegalClassification < ApplicationRecord
  self.table_name = "process_legal_classifications"

  belongs_to :process, class_name: "Sip::Process"
  belongs_to :legal_reference
  belongs_to :created_by, class_name: "User"
end
