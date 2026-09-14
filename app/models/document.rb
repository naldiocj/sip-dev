class Document < ApplicationRecord
  include Scopeable

  belongs_to :process, class_name: "Sip::Process", foreign_key: :process_id, optional: true
  belongs_to :uploader, class_name: "User", foreign_key: :uploader_id, optional: true
  has_one_attached :file

  validates :title, presence: true
  validates :status, inclusion: { in: %w[draft submitted approved signed archived] }

  before_validation :set_default_status, on: :create

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_process, ->(process_id) { where(process_id: process_id) if process_id.present? }
  scope :recent, -> { order(created_at: :desc).limit(20) }

  def self.in_user_scope?(user)
    return true if user.nil?
    return true if user.admin?
    false
  end

  def in_user_scope?(user)
    return true if user.nil?
    return true if user.admin?

    return false if process.blank?

    user.organizations.pluck(:id).include?(process.organizacao_id) ||
      process.responsavel_id == user.id ||
      uploader_id == user.id
  end

  private

  def set_default_status
    self.status ||= "draft"
  end
end
