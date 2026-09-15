class ConfidentialityLevel < ApplicationRecord
  has_many :processes, class_name: "Sip::Process", foreign_key: :confidentiality_level_id, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
