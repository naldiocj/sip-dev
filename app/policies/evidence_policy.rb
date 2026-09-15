class EvidencePolicy < ApplicationPolicy
  def index?
    can_view?
  end

  def show?
    can_view?
  end

  def create?
    can_create?
  end

  def update?
    can_update?
  end

  def destroy?
    admin?
  end

  def self.scope(pundit_user, scope)
    user = pundit_user.is_a?(Hash) ? pundit_user[:user] : pundit_user
    return scope.where(false) unless user

    org_ids = user.organizations.pluck(:id)

    scope.joins(:process)
         .where(processes: { organizacao_id: org_ids })
         .or(scope.where(collector_id: user.id))
         .distinct
  end
end
