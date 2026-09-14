class Admin::SipProcessesController < ApplicationController
  before_action :set_process, only: [ :show, :edit, :update, :destroy, :distribute, :return, :conclude, :close, :archive ]
  before_action :set_form_data, only: [ :new, :create, :edit, :update ]

  def index
    @processes = policy_scope(Sip::Process)
      .includes(:process_state, :organizacao, :responsavel, :created_by, :process_type, :process_nature)
      .order(created_at: :desc)
      .page(params[:page])
      .per(20)

    if params[:search].present?
      @processes = @processes.where("numero ILIKE ? OR titulo ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:state].present?
      @processes = @processes.joins(:process_state).where(process_states: { code: params[:state] })
    end
  end

  def show
    @transitions = @process.process_transitions.order(created_at: :desc).limit(20)
    @locations = @process.process_locations.order(started_at: :desc).limit(10)
    @assignments = @process.process_assignments.order(started_at: :desc)
    @deadlines = @process.process_deadlines.where(status: "EM_CURSO").order(due_at: :asc)
    @audit_events = @process.process_audit_events.order(created_at: :desc).limit(20)
  end

  def new
    @process = Sip::Process.new
    authorize @process
  end

  def create
    @process = Sip::Process.new(process_params)
    @process.created_by = current_user
    @process.updated_by = current_user
    authorize @process

    if @process.save
      redirect_to admin_process_path(@process), notice: "Processo criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @process
  end

  def update
    authorize @process

    if @process.update(process_params)
      redirect_to admin_process_path(@process), notice: "Processo actualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @process

    if @process.destroy
      redirect_to admin_processes_path, notice: "Processo eliminado com sucesso."
    else
      flash[:alert] = @process.errors.full_messages.join(", ")
      redirect_to admin_process_path(@process)
    end
  end

  def distribute
    authorize @process, :distribute?

    destination_org = params[:destination_organization_id].presence && Organization.find_by(id: params[:destination_organization_id])
    destination_user = params[:destination_user_id].presence && User.find_by(id: params[:destination_user_id])

    unless destination_org
      flash[:alert] = "Selecione uma organização de destino."
      return redirect_to admin_process_path(@process)
    end

    begin
      Processes::Distribute.call(
        process: @process,
        destination_organization: destination_org,
        destination_user: destination_user,
        performed_by: current_user,
        reason: params[:reason]
      )
      redirect_to admin_process_path(@process), notice: "Processo distribuído com sucesso."
    rescue Processes::Base::PermissionError => e
      flash[:alert] = "Sem permissão para distribuir."
      redirect_to admin_process_path(@process)
    rescue Processes::Base::StateError => e
      flash[:alert] = "Estado inválido para distribuição."
      redirect_to admin_process_path(@process)
    rescue Processes::Base::ScopeError => e
      flash[:alert] = "Fora do âmbito de competência."
      redirect_to admin_process_path(@process)
    rescue => e
      flash[:alert] = "Erro: #{e.message}"
      redirect_to admin_process_path(@process)
    end
  end

  private

  def set_process
    @process = Sip::Process.find(params[:id])
  end

  def set_form_data
    @process_types = ProcessType.all.order(:name)
    @process_natures = ProcessNature.all.order(:name)
    @process_origins = ProcessOrigin.all.order(:name)
    @process_priorities = ProcessPriority.all.order(:name)
    @confidentiality_levels = ConfidentialityLevel.all.order(:name)
    @process_states = ProcessState.where(active: true).order(:code)
    @organizations = Organization.where.not(level: "root").order(:level, :code)
    @users = User.where(status: "active").order(:first_name, :last_name)
  end

  def process_params
    params.require(:process).permit(
      :numero, :ano, :titulo, :resumo, :data_entrada,
      :process_type_id, :process_nature_id, :process_origin_id,
      :process_priority_id, :confidentiality_level_id, :process_state_id,
      :organizacao_id, :responsavel_id
    )
  end
end
