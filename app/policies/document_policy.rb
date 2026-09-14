class DocumentPolicy < ApplicationPolicy
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

  def sign?
    can_sign?
  end

  def self.scope(pundit_user, scope)
    user = pundit_user.is_a?(Hash) ? pundit_user[:user] : pundit_user
    return scope.none unless user.present?

    org_ids = user.organizations.pluck(:id)
    scope.joins(:process)
         .where(sip_processes: { organizacao_id: org_ids })
         .or(scope.joins(:process).where(sip_processes: { responsavel_id: user.id }))
         .or(scope.joins(:process).where(sip_processes: { criador_id: user.id }))
  end
end
