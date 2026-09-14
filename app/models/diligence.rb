class Diligence < ApplicationRecord
  include Scopeable

  belongs_to :process, class_name: "Sip::Process", foreign_key: :process_id, optional: true
  belongs_to :responsavel, class_name: "User", foreign_key: :responsavel_id, optional: true
  belongs_to :diligencia_type, class_name: "DiligenceType", foreign_key: :diligencia_type_id, optional: true

  validates :descricao, presence: true
  validates :estado, inclusion: { in: %w[agendada em_andamento concluida cancelada] }

  before_validation :set_default_estado, on: :create

  scope :by_estado, ->(estado) { where(estado: estado) if estado.present? }
  scope :by_type, ->(type_id) { joins(:diligencia_type).where(diligence_types: { id: type_id }) if type_id.present? }
  scope :by_responsavel, ->(user_id) { where(responsavel_id: user_id) if user_id.present? }
  scope :active, -> { where.not(estado: %w[concluida cancelada]) }

  def self.in_user_scope?(user)
    return true if user.nil?
    return true if user.admin?
    false
  end

  def in_user_scope?(user)
    return true if user.nil?
    return true if user.admin?

    if process.present?
      user.organizations.pluck(:id).include?(process.organizacao_id) ||
        process.responsavel_id == user.id
    else
      responsavel_id == user.id
    end
  end

  private

  def set_default_estado
    self.estado ||= "agendada"
  end
end
