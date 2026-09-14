class UserPolicy < ApplicationPolicy
  def index?
    admin? || can_view?
  end

  def show?
    admin? || record.id == user_model&.id
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  def activate?
    admin?
  end

  def deactivate?
    admin?
  end

  def self.scope(pundit_user, scope)
    user = pundit_user.is_a?(Hash) ? pundit_user[:user] : pundit_user
    return scope if admin_for?(pundit_user)

    # Non-admin users can only see their own record
    scope.where(id: user&.id)
  end

  def self.admin_for?(pundit_user)
    user = pundit_user.is_a?(Hash) ? pundit_user[:user] : pundit_user
    user&.has_profile?("ADMIN") == true
  end
end
