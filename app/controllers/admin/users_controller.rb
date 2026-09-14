class Admin::UsersController < ApplicationController
  before_action :set_user, only: [ :show, :edit, :update, :destroy, :activate, :deactivate ]
  authorize_resource

  def index
    @users = policy_scope(User).includes(:organization, :assigned_profiles).order(:created_at)
    @profiles = Profile.all
    @organizations = Organization.where(level: %w[direccao departamento seccao piquete]).order(:level, :code)
  end

  def show
    @assignments = @user.user_assignments.includes(:profile, :organization).order(:started_at)
  end

  def new
    @user = User.new
    @profiles = Profile.all
    @organizations = Organization.where(level: %w[direccao departamento seccao piquete]).order(:level, :code)
    authorize @user
  end

  def create
    @user = User.new(user_params)
    @profiles = Profile.all
    @organizations = Organization.where(level: %w[direccao departamento seccao piquete]).order(:level, :code)
    authorize @user

    if @user.save
      # Create Rodauth account
      Account.find_or_create_by!(login: @user.username) do |account|
        account.email = @user.email
        account.password_hash = BCrypt::Password.create(@user.password, cost: 4)
        account.verified_at = Time.current
      end

      # Create user assignment if profile and organization selected
      if params[:user][:profile_id].present? && params[:user][:organization_id].present?
        UserAssignment.create!(
          user: @user,
          organization_id: params[:user][:organization_id],
          profile_id: params[:user][:profile_id],
          role: Profile.find(params[:user][:profile_id])&.code,
          started_at: Time.current
        )
      end

      redirect_to admin_user_path(@user), notice: "Utilizador criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @profiles = Profile.all
    @organizations = Organization.where(level: %w[direccao departamento seccao piquete]).order(:level, :code)
  end

  def update
    @profiles = Profile.all
    @organizations = Organization.where(level: %w[direccao departamento seccao piquete]).order(:level, :code)

    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "Utilizador actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    Account.find_by(id: @user.id)&.destroy
    redirect_to admin_users_path, notice: "Utilizador eliminado."
  end

  def activate
    @user.update!(status: "active")
    redirect_to admin_user_path(@user), notice: "Utilizador activado."
  end

  def deactivate
    @user.update!(status: "inactive")
    redirect_to admin_user_path(@user), notice: "Utilizador desactivado."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation,
                                 :first_name, :last_name, :organization_id, :profile_id, :status)
  end
end
