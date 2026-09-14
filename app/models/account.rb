class Account < ApplicationRecord
  # ── Devise modules ──────────────────────────────────────────────────────
  # database_authenticatable → password_hash (see custom accessors below)
  # lockable                 → locked_at + failed_login_count
  # confirmable              → verified_at (confirmed_at) + verification_token
  # recoverable              → reset_password_token
  # rememberable             → remember_created_at
  # trackable                → sign_in_count, current/last_sign_in_*
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable, :confirmable, :trackable

  self.table_name = "accounts"

  # ── Column overrides (Devise expects `encrypted_password`, we have `password_hash`) ──
  def encrypted_password
    password_hash
  end

  def encrypted_password=(val)
    self.password_hash = val
  end

  # ── Login column (use :login instead of default :email for lookup) ─────
  def self.find_for_database_authentication(qualified_conditions)
    login = qualified_conditions[:login]
    where(qualified_conditions.except(:login)).or(
      where(login: login)
    ).first
  end

  # ── Existing business logic (preserved) ─────────────────────────────────
  has_one :user, foreign_key: :id, primary_key: :id, dependent: :destroy

  validates :login, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: /\A[^@\s]+@[^@\s]+\z/ }

  scope :active, -> {
    where("locked_at IS NULL OR locked_at < ?", 10.minutes.ago)
  }
  scope :locked, -> {
    where.not(locked_at: nil).where("locked_at > ?", 10.minutes.ago)
  }

  def capabilities
    return [] unless user
    user.assigned_profiles.flat_map { |p| p.capabilities.pluck(:name) }.uniq
  end

  def admin?
    user&.has_profile?("ADMIN") == true
  end

  # ── Devise lockable: map to existing failed_login_count + locked_at ─────
  def unlock_access!
    update!(locked_at: nil, failed_login_count: 0)
  end

  def lock!
    # Let Devise handle it via failed_attempts → locked_at
    super
  end

  # Override failed_attempts persistence to use our column
  def self.increment_failed_attempts_count(account)
    account.increment_failed_logins!
  end

  def self.clear_failed_attempts_count(account)
    account.reset_failed_logins!
  end

  # ── Devise confirmable: map to existing verified_at ─────────────────────
  def confirm!
    update!(verified_at: Time.current)
  end

  def confirmation_required?
    verified_at.blank?
  end

  def confirmed?
    verified_at.present?
  end

  def send_confirmation_instructions(options = {})
    generate_verification_token!
    # TODO: send confirmation email with token
    true
  end

  def generate_verification_token!
    update!(verification_token: SecureRandom.urlsafe_base64(32))
  end

  # ── Existing helpers ────────────────────────────────────────────────────
  def verify_password?(password)
    return false unless password_hash
    BCrypt::Password.new(password_hash) == password
  end

  def increment_failed_logins!
    self.failed_login_count = (failed_login_count || 0) + 1
    if failed_login_count >= 5
      lock!
    else
      save!
    end
  end

  def reset_failed_logins!
    update!(failed_login_count: 0, locked_at: nil)
  end
end
