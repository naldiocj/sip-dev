class CapabilityPolicy < ApplicationPolicy
  def index?
    admin? || can_view?
  end

  def show?
    admin? || can_view?
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
end
