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

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return @scope if admin?

      @scope.where(id: @user&.id)
    end

    def admin?
      @user&.has_profile?("ADMIN") == true
    end
  end
end
