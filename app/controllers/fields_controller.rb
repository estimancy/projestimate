class FieldsController < ApplicationController
  # GET /fields/new
  # GET /fields/new.json
  def new
    @field = Field.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @field }
    end
  end

  # GET /fields/1/edit
  def edit
    @field = Field.find(params[:id])
  end

  # POST /fields
  # POST /fields.json
  def create
    @field = Field.new(params[:field])

    respond_to do |format|
      if @field.save
        format.html { redirect_to edit_organization_path(@field.organization_id), notice: 'Field was successfully created.' }
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
    @field = Field.find(params[:id])

    respond_to do |format|
      if @field.update_attributes(params[:field])
        format.html { redirect_to @field.organization_id, notice: 'Field was successfully updated.' }
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
    @field = Field.find(params[:id])
    organization_id = @field.organization_id
    @field.destroy

    respond_to do |format|
      format.html { redirect_to organization_id }
      format.json { head :no_content }
    end
  end
end
