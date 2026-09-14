class ProfileCapability < ApplicationRecord
  belongs_to :profile
  belongs_to :capability

  validates :profile_id, uniqueness: { scope: :capability_id }
end
