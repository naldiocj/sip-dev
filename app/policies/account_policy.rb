class AccountPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin? || record.id == account&.id
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

  def unlock?
    admin?
  end
end
