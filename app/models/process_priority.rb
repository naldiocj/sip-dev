class ProcessPriority < ApplicationRecord
  has_many :processes, class_name: "Sip::Process", foreign_key: :process_priority_id, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
