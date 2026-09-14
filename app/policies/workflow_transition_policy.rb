class WorkflowTransitionPolicy < ApplicationPolicy
  def index?
    can_view?
  end

  def show?
    can_view?
  end

  def create?
    false # Transições são criadas pelo sistema, nunca directamente
  end

  def self.scope(_user, scope)
    scope.joins(:process)
         .joins(processes_table: :organizacao)
         .where(organizations: { id: user_model&.organizations&.pluck(:id) || [] })
         .distinct
  end
end
