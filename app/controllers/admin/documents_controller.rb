class Admin::DocumentsController < ApplicationController
  before_action :set_document, only: [ :show, :edit, :update, :destroy, :download ]
  before_action :set_form_data, only: [ :new, :create, :edit, :update ]

  def index
    @documents = policy_scope(Document)
      .includes(:process, :uploader)
      .order(created_at: :desc)
      .page(params[:page])
      .per(20)

    if params[:search].present?
      @documents = @documents.where("title ILIKE ?", "%#{params[:search]}%")
    end

    if params[:status].present?
      @documents = @documents.by_status(params[:status])
    end

    if params[:process_id].present?
      @documents = @documents.by_process(params[:process_id])
    end
  end

  def show
    @process = @document.process
  end

  def new
    @document = Document.new
    authorize @document
  end

  def create
    @document = Document.new(document_params)
    @document.uploader = current_user
    authorize @document

    if @document.save
      redirect_to admin_document_path(@document), notice: "Documento criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @document
  end

  def update
    authorize @document

    if @document.update(document_params)
      redirect_to admin_document_path(@document), notice: "Documento actualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @document

    if @document.destroy
      redirect_to admin_documents_path, notice: "Documento eliminado com sucesso."
    else
      flash[:alert] = @document.errors.full_messages.join(", ")
      redirect_to admin_document_path(@document)
    end
  end

  def download
    authorize @document
    if @document.file.attached?
      send_data @document.file.read, filename: @document.file.filename.to_s, type: @document.file.content_type
    else
      flash[:alert] = "Nenhum ficheiro anexado."
      redirect_to admin_document_path(@document)
    end
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def set_form_data
    @processes = policy_scope(Sip::Process).order(:numero).limit(100)
    @statuses = %w[draft submitted approved signed archived]
  end

  def document_params
    params.require(:document).permit(:title, :description, :status, :process_id, :file)
  end
end
