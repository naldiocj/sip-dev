class ConfirmationsController < Devise::ConfirmationsController
  skip_before_action :authenticate_user!, only: [:new, :create, :show]
  skip_after_action :verify_authorized, :verify_policy_scoped

  protected

  def after_resending_confirmation_instructions_path_for(resource)
    root_path
  end

  def after_confirmation_path_for(_resource_name, _resource)
    sign_in_path(:account)
  end
end
