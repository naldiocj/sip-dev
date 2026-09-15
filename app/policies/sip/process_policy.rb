module Sip
  class ProcessPolicy < ApplicationPolicy
    def distribute?
      account_has_capability?("PROCESSO_DISTRIBUTE")
    end

    def assign?
      account_has_capability?("PROCESSO_ASSIGN")
    end

    def return?
      account_has_capability?("PROCESSO_RETURN")
    end

    def submit?
      account_has_capability?("PROCESSO_SUBMIT")
    end

    def close?
      account_has_capability?("PROCESSO_CLOSE")
    end

    def sign?
      account_has_capability?("DOCUMENT_SIGN")
    end

    def audit?
      can_audit?
    end

    def unlock?
      admin?
    end

    def activate?
      admin?
    end

    def deactivate?
      admin?
    end

    def self.scope(pundit_user, scope)
      return scope.where.not(id: nil) if admin_for?(pundit_user)

      user = pundit_user.is_a?(Hash) ? pundit_user[:user] : pundit_user
      org_ids = user&.organizations&.pluck(:id) || []
      scope.joins(:organizacao).where(organizations: { id: org_ids }).distinct
    end

    def self.admin_for?(pundit_user)
      user = pundit_user.is_a?(Hash) ? pundit_user[:user] : pundit_user
      user&.has_profile?("ADMIN") == true
    end
  end
end
