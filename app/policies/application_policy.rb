class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    can_view?
  end

  def show?
    can_view?
  end

  def create?
    can_create?
  end

  def new?
    create?
  end

  def update?
    can_update?
  end

  def edit?
    update?
  end

  def destroy?
    can_delete?
  end

  def distribute?
    can_distribute?
  end

  def assign?
    can_assign?
  end

  def return?
    can_return?
  end

  def submit?
    can_submit?
  end

  def close?
    can_close?
  end

  def sign?
    can_sign?
  end

  def audit?
    can_audit?
  end

  def unlock?
    admin?
  end

  def activate?
    admin?
  end

  def deactivate?
    admin?
  end

  def complete?
    account_has_capability?("DILIGENCIA_COMPLETE")
  end

  def execute?
    account_has_capability?("MANDADO_EXECUTE")
  end

  # ── Regras base ──
  def can_view?
    account_has_capability?("PROCESSO_VIEW") ||
      account_has_capability?("DOCUMENT_VIEW") ||
      account_has_capability?("TRAMITACAO_VIEW")
  end

  def can_create?
    account_has_capability?("PROCESSO_CREATE") ||
      account_has_capability?("DOCUMENT_CREATE") ||
      account_has_capability?("DILIGENCIA_CREATE") ||
      account_has_capability?("MANDADO_CREATE")
  end

  def can_update?
    account_has_capability?("PROCESSO_UPDATE") ||
      account_has_capability?("DOCUMENT_UPDATE")
  end

  def can_delete?
    account_has_capability?("PROCESSO_CLOSE")
  end

  def can_distribute?
    account_has_capability?("PROCESSO_DISTRIBUTE")
  end

  def can_assign?
    account_has_capability?("PROCESSO_ASSIGN")
  end

  def can_return?
    account_has_capability?("PROCESSO_RETURN")
  end

  def can_submit?
    account_has_capability?("PROCESSO_SUBMIT")
  end

  def can_close?
    account_has_capability?("PROCESSO_CLOSE")
  end

  def can_sign?
    account_has_capability?("DOCUMENT_SIGN")
  end

  def can_audit?
    account_has_capability?("AUDIT_VIEW")
  end

  def can_manage_users?
    account_has_capability?("USER_MANAGE")
  end

  def can_manage_organization?
    account_has_capability?("ORGANIZATION_MANAGE")
  end

  def can_configure_system?
    account_has_capability?("SYSTEM_CONFIGURE")
  end

  # ── Escopo organizacional ──
  def within_scope?(organization)
    return true if admin?
    return false unless user.present?

    user.is_a?(Hash) ? false : user.organizations.pluck(:id).include?(organization.id)
  end

  def admin?
    account&.admin? || (user.is_a?(Hash) && user[:user]&.has_profile?("ADMIN"))
  end

  private

  def account
    @account ||= begin
      acct = user.is_a?(Hash) ? user[:account] : user
      acct.is_a?(Account) ? acct : nil
    end
  end

  def user_model
    @user_model ||= begin
      u = user.is_a?(Hash) ? user[:user] : user
      u.is_a?(User) ? u : nil
    end
  end

  def account_has_capability?(cap_name)
    return false unless account
    account.capabilities.include?(cap_name)
  end
end
