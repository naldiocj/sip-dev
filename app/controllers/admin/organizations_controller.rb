class Admin::OrganizationsController < ApplicationController
  before_action :set_organization, only: [ :show, :edit, :update, :destroy ]
  authorize_resource

  def index
    @organizations = policy_scope(Organization)
  end

  def show
  end

  def new
    @organization = Organization.new
    @parents = available_parents
    authorize @organization
  end

  def create
    @organization = Organization.new(organization_params)
    @parents = available_parents
    authorize @organization

    if @organization.save
      redirect_to admin_organization_path(@organization), notice: "Organização criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @parents = available_parents
  end

  def update
    @parents = available_parents
    if @organization.update(organization_params)
      redirect_to admin_organization_path(@organization), notice: "Organização actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @organization.destroy
      redirect_to admin_organizations_path, notice: "Organização eliminada."
    else
      flash[:alert] = @organization.errors.full_messages.join(", ")
      redirect_to admin_organization_path(@organization)
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def available_parents
    # Show valid parents based on the target organization's level
    # This is handled by the model validation, here we just show all except self
    Organization.where.not(id: @organization&.id).order(:level, :code)
  end

  def organization_params
    params.require(:organization).permit(:name, :code, :level, :parent_id, :description)
  end
end
