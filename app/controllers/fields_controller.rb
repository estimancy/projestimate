class FieldsController < ApplicationController
  # GET /fields/new
  # GET /fields/new.json
  def new
    authorize! :manage, Field

    @field = Field.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @field }
    end
  end

  # GET /fields/1/edit
  def edit
    authorize! :show_custom_fields, Field
    @field = Field.find(params[:id])
  end

  # POST /fields
  # POST /fields.json
  def create
    authorize! :manage, Field

    @field = Field.new(params[:field])

    respond_to do |format|
      if @field.save
        format.html { redirect_to organization_setting_path(@field.organization_id, anchor: "tabs-fields"), notice: 'Field was successfully created.' }
        format.json { render json: @field, status: :created, location: @field }
      else
        format.html { render action: "new" }
        format.json { render json: @field.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fields/1
  # PUT /fields/1.json
  def update
    authorize! :manage, Field

    @field = Field.find(params[:id])
    @organization = @field.organization

    respond_to do |format|
      if @field.update_attributes(params[:field])
        format.html { redirect_to organization_setting_path(@organization, anchor: "tabs-fields"), notice: 'Field was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @field.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fields/1
  # DELETE /fields/1.json
  def destroy
    authorize! :manage, Field

    @field = Field.find(params[:id])
    organization_id = @field.organization_id
    @field.destroy

    respond_to do |format|
      format.html { redirect_to organization_setting_path(organization_id, anchor: "tabs-fields") }
      format.json { head :no_content }
    end
  end
end
