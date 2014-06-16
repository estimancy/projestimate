class SizeUnitsController < ApplicationController
  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  # GET /size_units/1
  # GET /size_units/1.json
  def show
    @size_unit = SizeUnit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @size_unit }
    end
  end

  # GET /size_units/new
  # GET /size_units/new.json
  def new
    @size_unit = SizeUnit.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @size_unit }
    end
  end

  # GET /size_units/1/edit
  def edit
    @size_unit = SizeUnit.find(params[:id])
  end

  # POST /size_units
  # POST /size_units.json
  def create
    @size_unit = SizeUnit.new(params[:size_unit])

    respond_to do |format|
      if @size_unit.save

        Organization.all.each do |o|
          OrganizationTechnology.all.each do |ot|
            SizeUnitType.all.each do |sut|
              TechnologySizeType.create(organization_id: o.id, organization_technology_id: ot.id, size_unit_id: @size_unit.id, size_unit_type_id: sut.id, value: 1)
            end
          end
        end

        format.html { redirect_to @size_unit, notice: 'Size unit was successfully created.' }
        format.json { render json: @size_unit, status: :created, location: @size_unit }
      else
        format.html { render action: "new" }
        format.json { render json: @size_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /size_units/1
  # PUT /size_units/1.json
  def update
    @size_unit = SizeUnit.find(params[:id])

    respond_to do |format|
      if @size_unit.update_attributes(params[:size_unit])
        format.html { redirect_to @size_unit, notice: 'Size unit was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @size_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /size_units/1
  # DELETE /size_units/1.json
  def destroy
    @size_unit = SizeUnit.find(params[:id])
    @size_unit.destroy

    respond_to do |format|
      format.html { redirect_to size_units_url }
      format.json { head :no_content }
    end
  end
end
