class ProcessType < ApplicationRecord
  has_many :sip_processes, foreign_key: :tipo_id, dependent: :restrict_with_error

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
