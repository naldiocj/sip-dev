class PasswordsController < Devise::PasswordsController
  skip_before_action :authenticate_account!, only: [ :new, :create, :edit, :update ]
  skip_after_action :verify_authorized, :verify_policy_scoped
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_resetting_password_path_for(resource)
    sign_in_path(:account)
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:password_update, keys: [ :password, :password_confirmation ])
  end
end
