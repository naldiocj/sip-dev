class Mandate < ApplicationRecord
  include Scopeable

  belongs_to :process, class_name: "Sip::Process", foreign_key: :process_id, optional: true
  belongs_to :emissor, class_name: "User", foreign_key: :emissor_id, optional: true

  validates :mandate_type, presence: true
  validates :destino, presence: true
  validates :descricao, presence: true
  validates :estado, inclusion: { in: %w[emitido em_andamento executado cancelado] }
  validates :data_prazo, presence: true
  validates :data_emissao, presence: true

  scope :by_estado, ->(estado) { where(estado: estado) if estado.present? }
  scope :by_type, ->(type) { where(mandate_type: type) if type.present? }
  scope :by_process, ->(process_id) { where(process_id: process_id) if process_id.present? }
  scope :overdue, -> { where('data_prazo < ?', Time.current).where(estado: %w[emitido em_andamento]) }
  scope :active, -> { where.not(estado: %w[executado cancelado]) }

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
      emissor_id == user.id
  end

  private

  def set_default_estado
    self.estado ||= "emitido"
  end
end
