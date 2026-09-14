class Evidence < ApplicationRecord
  include Scopeable

  belongs_to :process, class_name: "Sip::Process", foreign_key: :process_id, optional: true
  belongs_to :collector, class_name: "User", foreign_key: :collector_id, optional: true
  has_one_attached :file

  validates :evidence_type, presence: true
  validates :descricao, presence: true

  scope :by_type, ->(type) { where(evidence_type: type) if type.present? }
  scope :by_process, ->(process_id) { where(process_id: process_id) if process_id.present? }
  scope :by_collector, ->(user_id) { where(collector_id: user_id) if user_id.present? }
  scope :recent, -> { order(collected_at: :desc).limit(20) }

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
      collector_id == user.id
  end
end
