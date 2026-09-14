class ProcessOrigin < ApplicationRecord
  has_many :processes, foreign_key: :process_origin_id, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
