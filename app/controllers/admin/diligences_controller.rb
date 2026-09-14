class Admin::DiligencesController < ApplicationController
  before_action :set_diligence, only: [ :show, :edit, :update, :destroy ]
  before_action :set_form_data, only: [ :new, :create, :edit, :update ]

  def index
    @diligences = policy_scope(Diligence)
      .includes(:process, :responsavel, :diligencia_type)
      .order(created_at: :desc)
      .page(params[:page])
      .per(20)

    if params[:search].present?
      @diligences = @diligences.where("descricao ILIKE ?", "%#{params[:search]}%")
    end

    if params[:estado].present?
      @diligences = @diligences.by_estado(params[:estado])
    end

    if params[:type_id].present?
      @diligences = @diligences.by_type(params[:type_id])
    end

    if params[:responsavel_id].present?
      @diligences = @diligences.by_responsavel(params[:responsavel_id])
    end
  end

  def show
    @process = @diligence.process
    @transitions = @process&.process_transitions&.order(created_at: :desc)&.limit(10) || []
  end

  def new
    @diligence = Diligence.new
    authorize @diligence
  end

  def create
    @diligence = Diligence.new(diligence_params)
    @diligence.created_by = current_user
    authorize @diligence

    if @diligence.save
      redirect_to admin_diligence_path(@diligence), notice: "Diligência criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @diligence
  end

  def update
    authorize @diligence

    if @diligence.update(diligence_params)
      redirect_to admin_diligence_path(@diligence), notice: "Diligência actualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @diligence

    if @diligence.destroy
      redirect_to admin_diligences_path, notice: "Diligência eliminada com sucesso."
    else
      flash[:alert] = @diligence.errors.full_messages.join(", ")
      redirect_to admin_diligence_path(@diligence)
    end
  end

  private

  def set_diligence
    @diligence = Diligence.find(params[:id])
  end

  def set_form_data
    @processes = policy_scope(Sip::Process).where.not(id: nil).order(:numero).limit(50)
    @responsables = User.where(status: "active").order(:first_name, :last_name)
    @types = DiligenceType.all.order(:name)
  end

  def diligence_params
    params.require(:diligence).permit(
      :process_id, :responsavel_id, :diligencia_type_id,
      :descricao, :estado, :data_prevista, :data_real,
      :result
    )
  end
end
