class Profile < ApplicationRecord
  has_many :profile_capabilities, dependent: :destroy
  has_many :capabilities, through: :profile_capabilities
  has_many :user_assignments, dependent: :restrict_with_error

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
