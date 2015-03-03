class SizeUnitTypesController < ApplicationController
  load_and_authorize_resource :except => [:index]

  def index
    authorize! :show_modules_instances, ModuleProject

    @size_unit_types = SizeUnitType.all
  end

  def show
    authorize! :show_modules_instances, ModuleProject
    @size_unit_type = SizeUnitType.find(params[:id])
  end

  def new
    authorize! :manage_modules_instances, ModuleProject

    @size_unit_type = SizeUnitType.new
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @size_unit_type = SizeUnitType.find(params[:id])
    @organization = @size_unit_type.organization #|| Organization.find(params[:organization_id])
  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @size_unit_type = SizeUnitType.new(params[:size_unit_type])

    if @size_unit_type.save

      @size_unit_type.organization.organization_technologies.each do |ot|
        SizeUnit.all.each do |su|
          TechnologySizeType.create(organization_id: @size_unit_type.organization_id,
                                    organization_technology_id: ot.id,
                                    size_unit_id: su.id,
                                    size_unit_type_id: @size_unit_type.id,
                                    value: 1)
        end
      end

      redirect_to organization_setting_path(@organization.id), notice: 'Size unit type was successfully created.'
    else
      render action: "new", :organization_id => @organization.id
    end
  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @size_unit_type = SizeUnitType.find(params[:id])

    if @size_unit_type.update_attributes(params[:size_unit_type])
      redirect_to organization_setting_path(@organization.id), notice: 'Size unit type was successfully updated.'
    else
      render action: "edit", :organization_id => @organization.id
    end
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @size_unit_type = SizeUnitType.find(params[:id])
    @size_unit_type.destroy
    redirect_to organization_setting_path(@organization.id), notice: 'Size unit type was successfully deleted.'
  end
end
