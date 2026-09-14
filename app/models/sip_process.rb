class SipProcess < ApplicationRecord
  include Scopeable
  belongs_to :tipo, class_name: "ProcessType", foreign_key: :tipo_id
  belongs_to :organizacao
  belongs_to :responsavel, class_name: "User", foreign_key: :responsavel_id, optional: true
  belongs_to :criador, class_name: "User", foreign_key: :criador_id

  has_many :workflow_transitions, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :diligences, dependent: :destroy
  has_many :mandates, dependent: :destroy
  has_many :evidences, dependent: :destroy

  validates :numero, presence: true, uniqueness: true
  validates :prioridade, inclusion: { in: %w[normal alta urgente] }

  before_validation :set_default_estado, on: :create
  before_validation :set_default_prioridade, on: :create

  private

  def set_default_estado
    self.estado ||= "REGISTADO"
  end

  def set_default_prioridade
    self.prioridade ||= "normal"
  end
end
