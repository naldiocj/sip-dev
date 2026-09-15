class AuthController < ApplicationController
  layout false
  skip_before_action :authenticate_account!, only: [ :login, :create_account, :reset_password_request, :reset_password ]
  skip_after_action :verify_authorized,  only: [ :login, :create_account, :reset_password_request, :reset_password ]
  skip_after_action :verify_policy_scoped, only: [ :login, :create_account, :reset_password_request, :reset_password ]

  # ── Login page ──────────────────────────────────────────────────────────
  def login
    render "auth/login"
  end

  # ── Login submission ────────────────────────────────────────────────────
  def create
    account = Account.find_by(login: params[:login])

    if account&.verify_password?(params[:password])
      if account.locked?
        flash[:alert] = "Conta bloqueada. Aguarde 10 minutos."
        render "auth/login" and return
      end

      session[:account_id] = account.id
      session[:user_id]    = account.id
      session[:last_login_at] = Time.now.to_i
      account.reset_failed_logins!
      account.update(last_login_at: Time.now)

      flash[:notice] = "Sessão iniciada com sucesso."
      redirect_to admin_dashboard_path
    else
      if account
        account.increment_failed_logins!
        if account.failed_login_count >= 5
          account.lock!
        end
      end
      @error = "Email ou utilizador não encontrado."
      @login = params[:login]
      render "auth/login"
    end
  end

  # ── Logout ──────────────────────────────────────────────────────────────
  def destroy
    session.delete(:account_id)
    session.delete(:user_id)
    session.delete(:last_login_at)
    flash[:notice] = "Sessão terminada."
    redirect_to root_path
  end

  # ── Create account page ─────────────────────────────────────────────────
  def create_account
    render "auth/create_account"
  end

  # ── Create account submission ───────────────────────────────────────────
  def create_account_create
    account = Account.new(login: params[:login], email: params[:email])
    account.password_hash = BCrypt::Password.create(params[:password], cost: 12)

    if account.save
      session[:account_id] = account.id
      session[:user_id]    = account.id
      flash[:notice] = "Conta criada com sucesso. Bem-vindo!"
      redirect_to admin_dashboard_path
    else
      @error = account.errors.full_messages.join(", ")
      @login = params[:login]
      @email = params[:email]
      render "auth/create_account"
    end
  end

  # ── Reset password request page ─────────────────────────────────────────
  def reset_password_request
    render "auth/reset_password"
  end

  # ── Reset password submission ───────────────────────────────────────────
  def reset_password_create
    account = Account.find_by(login: params[:login])
    if account
      token = account.generate_verification_token!
      # TODO: Send email with reset link
      Rails.logger.info "[SIP] Password reset for #{account.email}, token: #{token}"
    end
    flash[:notice] = "Instruções enviadas para o seu email."
    redirect_to auth_login_path
  end

  # ── Reset password form ─────────────────────────────────────────────────
  def reset_password
    @token = params[:token]
    @login = params[:login]
    render "auth/reset_password_form"
  end

  # ── Reset password submission ───────────────────────────────────────────
  def reset_password_update
    account = Account.find_by(verification_token: params[:token])
    if account && account.verify_password?(params[:current_password])
      if params[:password] == params[:password_confirmation]
        account.update!(password_hash: BCrypt::Password.create(params[:password], cost: 12))
        flash[:notice] = "Palavra-passe actualizada com sucesso."
        redirect_to auth_login_path
      else
        @error = "As palavras-passe não coincidem."
        render "auth/reset_password_form"
      end
    else
      @error = "Token inválido ou palavra-passe actual incorreta."
      render "auth/reset_password_form"
    end
  end
end
