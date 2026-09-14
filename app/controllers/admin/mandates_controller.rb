class Admin::MandatesController < ApplicationController
  before_action :set_mandate, only: [ :show, :edit, :update, :destroy, :execute, :cancel ]
  before_action :set_form_data, only: [ :new, :create, :edit, :update ]

  def index
    @mandates = policy_scope(Mandate)
      .includes(:process, :emissor)
      .order(created_at: :desc)
      .page(params[:page])
      .per(20)

    if params[:search].present?
      @mandates = @mandates.where("descricao ILIKE ? OR destino ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:estado].present?
      @mandates = @mandates.by_estado(params[:estado])
    end

    if params[:type].present?
      @mandates = @mandates.by_type(params[:type])
    end

    if params[:process_id].present?
      @mandates = @mandates.by_process(params[:process_id])
    end

    @overdue_count = Mandate.overdue.count
  end

  def show
    @process = @mandate.process
  end

  def new
    @mandate = Mandate.new
    authorize @mandate
  end

  def create
    @mandate = Mandate.new(mandate_params)
    @mandate.emissor = current_user
    authorize @mandate

    if @mandate.save
      redirect_to admin_mandate_path(@mandate), notice: "Mandado criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @mandate
  end

  def update
    authorize @mandate

    if @mandate.update(mandate_params)
      redirect_to admin_mandate_path(@mandate), notice: "Mandado actualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @mandate

    if @mandate.destroy
      redirect_to admin_mandates_path, notice: "Mandado eliminado com sucesso."
    else
      flash[:alert] = @mandate.errors.full_messages.join(", ")
      redirect_to admin_mandate_path(@mandate)
    end
  end

  def execute
    authorize @mandate
    if @mandate.update!(estado: "executado", data_execucao: Time.current)
      redirect_to admin_mandate_path(@mandate), notice: "Mandado executado com sucesso."
    else
      redirect_to admin_mandate_path(@mandate), alert: @mandate.errors.full_messages.join(", ")
    end
  end

  def cancel
    authorize @mandate
    if @mandate.update!(estado: "cancelado")
      redirect_to admin_mandate_path(@mandate), notice: "Mandado cancelado com sucesso."
    else
      redirect_to admin_mandate_path(@mandate), alert: @mandate.errors.full_messages.join(", ")
    end
  end

  private

  def set_mandate
    @mandate = Mandate.find(params[:id])
  end

  def set_form_data
    @processes = policy_scope(Sip::Process).order(:numero).limit(100)
    @emissores = User.where(status: "active").order(:first_name, :last_name)
    @mandate_types = %w[MANDADO_JUDICIAL BUSCA_E_APREENSAO IDENTIFICACAO INTERCEPTACAO PERICIA OUTRO]
  end

  def mandate_params
    params.require(:mandate).permit(
      :process_id, :emissor_id, :mandate_type, :destino,
      :descricao, :estado, :data_emissao, :data_prazo
    )
  end
end
