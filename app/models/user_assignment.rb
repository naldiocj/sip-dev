class UserAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :organization
  belongs_to :profile

  validates :started_at, presence: true
  validate :ended_at_after_started_at, if: -> { ended_at.present? }

  def active?
    ended_at.nil? || ended_at.future?
  end

  private

  def ended_at_after_started_at
    errors.add(:ended_at, "must be after started_at") if ended_at < started_at
  end
end
