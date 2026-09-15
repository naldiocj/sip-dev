class ProcessNature < ApplicationRecord
  has_many :processes, class_name: "Sip::Process", foreign_key: :process_nature_id, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
