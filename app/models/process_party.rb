class ProcessParty < ApplicationRecord
  self.table_name = "process_parties"

  belongs_to :process, class_name: "Sip::Process"
  belongs_to :person
  belongs_to :party_type
  belongs_to :created_by, class_name: "User"

  scope :active, -> { where(status: "ATIVO") }
  scope :by_started_at, -> { order(started_at: :desc) }
end
