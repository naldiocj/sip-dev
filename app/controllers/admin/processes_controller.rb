class Admin::ProcessesController < ApplicationController
  # authorize_resource is handled by Pundit via skip_before_action below

  def index
    @processes = policy_scope(Sip::Process).page(params[:page]).per(20)
    render "admin/processes/index"
  end

  def show
    @process = policy_scope(Sip::Process).find(params[:id])
    authorize! @process
  end

  def new
    @process = Sip::Process.new
    authorize! @process
  end

  def create
    @process = Sip::Process.new(process_params)
    authorize! @process
    @process.criador = current_user
    if @process.save
      redirect_to admin_process_path(@process), notice: "Processo criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @process = policy_scope(Sip::Process).find(params[:id])
    authorize! @process
  end

  def update
    @process = policy_scope(Sip::Process).find(params[:id])
    authorize! @process
    if @process.update(process_params)
      redirect_to admin_process_path(@process), notice: "Processo atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def distribute
    @process = policy_scope(Sip::Process).find(params[:id])
    authorize! @process, :distribute?
    destination_user = params[:destination_user_id].presence && User.find_by(id: params[:destination_user_id])
    if destination_user
      @process.update!(responsavel_id: destination_user.id)
      @process.workflow_transitions.create!(
        actor: current_user,
        from_state: @process.estado,
        to_state: @process.estado,
        action: "distribute",
        notes: params[:notes]
      )
      redirect_to admin_process_path(@process), notice: "Processo distribuído."
    else
      flash[:alert] = "Seleccione um utilizador."
      render :show
    end
  end

  private

  def process_params
    params.require(:process).permit(
      :numero, :ano, :tipo_id, :organizacao_id, :responsavel_id,
      :prioridade, :estado, :titulo, :descricao
    )
  end
end
