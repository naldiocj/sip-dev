class DiligenceType < ApplicationRecord
  has_many :diligences, foreign_key: :diligencia_type_id

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  scope :by_code, ->(code) { where(code: code.upcase) if code.present? }
end
