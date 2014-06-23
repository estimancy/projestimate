class SizeUnitTypesController < ApplicationController
  #include DataValidationHelper #Module for master data changes validation
  #before_filter :get_record_statuses

  def index
    @size_unit_types = SizeUnitType.all

  end

  def show
    @size_unit_type = SizeUnitType.find(params[:id])
  end

  # GET /size_unit_types/new
  # GET /size_unit_types/new.json
  def new
    @size_unit_type = SizeUnitType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @size_unit_type }
    end
  end

  # GET /size_unit_types/1/edit
  def edit
    @size_unit_type = SizeUnitType.find(params[:id])
  end

  # POST /size_unit_types
  # POST /size_unit_types.json
  def create
    @size_unit_type = SizeUnitType.new(params[:size_unit_type])
    @size_unit_type.organization_id = params[:size_unit_type][:organization_id]

    respond_to do |format|
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

        format.html { redirect_to @size_unit_type, notice: 'Size unit type was successfully created.' }
        format.json { render json: @size_unit_type, status: :created, location: @size_unit_type }
      else
        format.html { render action: "new" }
        format.json { render json: @size_unit_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /size_unit_types/1
  # PUT /size_unit_types/1.json
  def update
    @size_unit_type = SizeUnitType.find(params[:id])
    @size_unit_type.organization_id = params[:size_unit_type][:organization_id]

    respond_to do |format|
      if @size_unit_type.update_attributes(params[:size_unit_type])
        format.html { redirect_to @size_unit_type, notice: 'Size unit type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @size_unit_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /size_unit_types/1
  # DELETE /size_unit_types/1.json
  def destroy
    @size_unit_type = SizeUnitType.find(params[:id])
    @size_unit_type.destroy

    respond_to do |format|
      format.html { redirect_to size_unit_types_url }
      format.json { head :no_content }
    end
  end
end
