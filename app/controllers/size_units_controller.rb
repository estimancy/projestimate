class SizeUnitsController < ApplicationController
  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  load_and_authorize_resource :except => [:index]

  def show
    @size_unit = SizeUnit.find(params[:id])
  end

  def new
    @size_unit = SizeUnit.new
    set_breadcrumbs "Organizations" => "/organizationals_params"
  end

  def edit
    @size_unit = SizeUnit.find(params[:id])
    set_breadcrumbs "Organizations" => "/organizationals_params", @size_unit.name => edit_size_unit_path(@size_unit)
  end

  def create
    @size_unit = SizeUnit.new(params[:size_unit])

    if @size_unit.save
      Organization.all.each do |o|
        OrganizationTechnology.all.each do |ot|
          SizeUnitType.all.each do |sut|
            TechnologySizeType.create(organization_id: o.id, organization_technology_id: ot.id, size_unit_id: @size_unit.id, size_unit_type_id: sut.id, value: 1)
          end
        end
      end
      redirect_to "/organizational_params"
    end
  end

  def update
    @size_unit = SizeUnit.find(params[:id])

    respond_to do |format|
      if @size_unit.update_attributes(params[:size_unit])
        format.html { redirect_to "/organizational_params", notice: 'Size unit was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @size_unit = SizeUnit.find(params[:id])
    @size_unit.destroy
    redirect_to "/organizational_params"
  end
end
