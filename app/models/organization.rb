class Organization < ApplicationRecord
  belongs_to :parent, class_name: "Organization", foreign_key: :parent_id, optional: true
  has_many :children, class_name: "Organization", foreign_key: :parent_id, dependent: :restrict_with_error
  has_many :users, dependent: :restrict_with_error
  has_many :user_assignments, dependent: :destroy
  has_many :processes, foreign_key: :organizacao_id, dependent: :restrict_with_error

  VALID_LEVELS = %w[
    root
    direccao_geral
    direccao
    piquete
    departamento
    seccao
  ].freeze

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :level, inclusion: { in: VALID_LEVELS }

  # Regras de hierarquia: cada nível só aceita filhos permitidos
  CHILD_LEVELS = {
    "root"         => %w[direccao_geral],
    "direccao_geral" => %w[direccao],
    "direccao"     => %w[piquete departamento],
    "departamento" => %w[seccao],
    "piquete"      => [],
    "seccao"       => []
  }.freeze

  validate :child_level_allowed

  private

  def child_level_allowed
    return if parent.blank? || parent.new_record?

    allowed_children = CHILD_LEVELS[parent.level] || []
    return if allowed_children.include?(level)

    errors.add(:level, "não é permitido como filho de #{parent.level} (#{parent.code})")
  end
end
