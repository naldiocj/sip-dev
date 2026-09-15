class RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_account!, only: [ :new, :create, :edit, :update ]
  skip_after_action :verify_authorized, :verify_policy_scoped
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_sign_up_path_for(resource)
    admin_dashboard_path
  end

  def after_update_path_for(resource)
    admin_dashboard_path
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :login, :email, :password, :password_confirmation ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :login, :email ])
  end
end
