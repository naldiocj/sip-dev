class LegalReference < ApplicationRecord
  self.table_name = "legal_references"

  has_many :process_legal_classifications, dependent: :destroy
  has_many :processes, through: :process_legal_classifications

  scope :active, -> { where(active: true) }
end
