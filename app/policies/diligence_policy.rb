class DiligencePolicy < ApplicationPolicy
  def index?
    can_view?
  end

  def show?
    can_view? && record.process.in_user_scope?(user_model)
  end

  def create?
    can_create?
  end

  def update?
    can_update? && record.process.in_user_scope?(user_model)
  end

  def destroy?
    admin?
  end

  def complete?
    account_has_capability?("DILIGENCIA_COMPLETE") && record.process.in_user_scope?(user_model)
  end

  def self.scope(_user, scope)
    scope.joins(:process)
         .joins(processes_table: :organizacao)
         .where(organizations: { id: user_model&.organizations&.pluck(:id) || [] })
         .distinct
  end
end
