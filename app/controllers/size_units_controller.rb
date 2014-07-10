class SizeUnitsController < ApplicationController
  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  # GET /size_units/1
  # GET /size_units/1.json
  def show
    @size_unit = SizeUnit.find(params[:id])
  end

  # GET /size_units/new
  # GET /size_units/new.json
  def new
    @size_unit = SizeUnit.new
    set_breadcrumbs "Dashboard" => "/dashboard", "Organizations" => "/organizationals_params"
  end

  # GET /size_units/1/edit
  def edit
    @size_unit = SizeUnit.find(params[:id])
    set_breadcrumbs "Dashboard" => "/dashboard", "Organizations" => "/organizationals_params", @size_unit.name => edit_size_unit_path(@size_unit)
  end

  # POST /size_units
  # POST /size_units.json
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

  # PUT /size_units/1
  # PUT /size_units/1.json
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

  # DELETE /size_units/1
  # DELETE /size_units/1.json
  def destroy
    @size_unit = SizeUnit.find(params[:id])
    @size_unit.destroy
    redirect_to "/organizational_params"
  end
end
