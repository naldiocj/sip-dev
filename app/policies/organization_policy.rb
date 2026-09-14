class OrganizationPolicy < ApplicationPolicy
  def index?
    can_view?
  end

  def show?
    can_view?
  end

  def create?
    can_manage_organization?
  end

  def update?
    can_manage_organization?
  end

  def destroy?
    can_manage_organization?
  end

  def self.scope(_user, scope)
    scope.order(:level, :code)
  end
end
