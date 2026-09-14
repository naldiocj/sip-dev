module Scopeable
  extend ActiveSupport::Concern

  class_methods do
    def in_user_scope?(user)
      return true if user.nil?
      return true if user.admin?

      user.organizations.pluck(:id).include?(organization_id) ||
        respond_to?(:responsavel_id) && responsavel_id == user.id ||
        respond_to?(:criador_id) && criador_id == user.id
    end
  end
end
