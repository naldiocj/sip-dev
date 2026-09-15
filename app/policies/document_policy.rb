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

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return @scope.none unless @user.present?

      org_ids = @user.organizations.pluck(:id)
      @scope.joins(:process)
            .where(processes: { organizacao_id: org_ids })
            .or(@scope.joins(:process).where(processes: { responsavel_id: @user.id }))
            .or(@scope.joins(:process).where(processes: { criador_id: @user.id }))
    end
  end
end
