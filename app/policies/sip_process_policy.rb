class SipProcessPolicy < ApplicationPolicy
  def index?
    can_view?
  end

  def show?
    can_view? && record.in_user_scope?(user_model)
  end

  def create?
    can_create?
  end

  def update?
    can_update? && record.in_user_scope?(user_model)
  end

  def destroy?
    admin?
  end

  def distribute?
    can_distribute? && record.in_user_scope?(user_model)
  end

  def assign?
    can_assign? && record.in_user_scope?(user_model)
  end

  def return?
    can_return? && record.in_user_scope?(user_model)
  end

  def submit?
    can_submit? && record.in_user_scope?(user_model)
  end

  def close?
    can_close? && record.in_user_scope?(user_model)
  end

  def self.scope(pundit_user, scope)
    user = pundit_user.is_a?(Hash) ? pundit_user[:user] : pundit_user
    return scope.none unless user.present?

    org_ids = user.organizations.pluck(:id)
    scope.where(organizacao_id: org_ids)
         .or(scope.where(responsavel_id: user.id))
         .or(scope.where(criador_id: user.id))
  end
end
