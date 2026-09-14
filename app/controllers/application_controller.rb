class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  allow_browser versions: :modern

  include Pundit::Authorization
  before_action :authenticate_user!
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :current_user, :current_profile, :current_account, :logged_in?, :can?

  private

  def current_user
    return @current_user if defined?(@current_user)
    account = warden.authenticate(scope: :account)
    @current_user = account&.user if account
    @current_user
  end

  def current_profile
    current_user&.assigned_profiles&.first
  end

  def current_account
    warden.authenticate(scope: :account)
  end

  def logged_in?
    warden.authenticated?(:account)
  end

  def can?(capability)
    account = current_account
    return false unless account
    account.capabilities.include?(capability.to_s.upcase)
  end

  def user_not_authorized
    flash[:alert] = "Não tem permissão para realizar esta acção."
    redirect_to(request.referrer || root_path)
  end
end
