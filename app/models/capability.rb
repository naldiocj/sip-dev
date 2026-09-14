class Capability < ApplicationRecord
  has_many :profile_capabilities, dependent: :destroy
  has_many :profiles, through: :profile_capabilities

  validates :name, presence: true
  validates :description, presence: true
end
