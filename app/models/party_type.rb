class PartyType < ApplicationRecord
  has_many :process_parties, dependent: :restrict_with_error
  has_many :processes, through: :process_parties

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
