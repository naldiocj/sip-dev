class User < ApplicationRecord
  belongs_to :organization, optional: true
  has_many :user_assignments, dependent: :destroy
  has_many :organizations, through: :user_assignments
  has_many :assigned_profiles, through: :user_assignments, source: :profile
  has_many :created_processes, class_name: "Sip::Process", foreign_key: :criador_id, dependent: :nullify
  has_many :managed_processes, class_name: "Sip::Process", foreign_key: :responsavel_id, dependent: :nullify
  has_many :workflow_transitions_as_actor, class_name: "WorkflowTransition", foreign_key: :actor_id, dependent: :nullify
  has_one :account, foreign_key: :id, primary_key: :id, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
  validates :username, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[active inactive suspended] }

  before_validation :set_default_status, on: :create
  scope :active, -> { where(status: "active") }

  def has_profile?(profile_code)
    assigned_profiles.exists?(code: profile_code)
  end

  def admin?
    has_profile?("ADMIN") || has_profile?("DIRECAO_GERAL")
  end

  def can?(capability_code)
    assigned_profiles.joins(:capabilities).exists?(capabilities: { name: capability_code.upcase })
  end

  def current_organization
    organization || organizations.first
  end

  private

  def set_default_status
    self.status ||= "active"
  end
end
