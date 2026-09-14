class Admin::EvidencesController < ApplicationController
  before_action :set_evidence, only: [ :show, :edit, :update, :destroy, :download ]
  before_action :set_form_data, only: [ :new, :create, :edit, :update ]

  def index
    @evidences = policy_scope(Evidence)
      .includes(:process, :collector)
      .order(created_at: :desc)
      .page(params[:page])
      .per(20)

    if params[:search].present?
      @evidences = @evidences.where("descricao ILIKE ?", "%#{params[:search]}%")
    end

    if params[:type].present?
      @evidences = @evidences.by_type(params[:type])
    end

    if params[:process_id].present?
      @evidences = @evidences.by_process(params[:process_id])
    end
  end

  def show
    @process = @evidence.process
  end

  def new
    @evidence = Evidence.new
    authorize @evidence
  end

  def create
    @evidence = Evidence.new(evidence_params)
    @evidence.collector = current_user
    authorize @evidence

    if @evidence.save
      redirect_to admin_evidence_path(@evidence), notice: "Evidência criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @evidence
  end

  def update
    authorize @evidence

    if @evidence.update(evidence_params)
      redirect_to admin_evidence_path(@evidence), notice: "Evidência actualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @evidence

    if @evidence.destroy
      redirect_to admin_evidences_path, notice: "Evidência eliminada com sucesso."
    else
      flash[:alert] = @evidence.errors.full_messages.join(", ")
      redirect_to admin_evidence_path(@evidence)
    end
  end

  def download
    authorize @evidence
    if @evidence.file.attached?
      send_data @evidence.file.read, filename: @evidence.file.filename.to_s, type: @evidence.file.content_type
    else
      flash[:alert] = "Nenhum ficheiro anexado."
      redirect_to admin_evidence_path(@evidence)
    end
  end

  private

  def set_evidence
    @evidence = Evidence.find(params[:id])
  end

  def set_form_data
    @processes = policy_scope(Sip::Process).order(:numero).limit(100)
    @collectors = User.where(status: "active").order(:first_name, :last_name)
    @evidence_types = %w[DOCUMENTO FOTO_AUDIO_VIDEO_PERICIA_TESTEMUNHO OUTRO]
  end

  def evidence_params
    params.require(:evidence).permit(:evidence_type, :descricao, :process_id, :collector_id, :collected_at, :file)
  end
end
