class TechnologiesController < ApplicationController
  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  load_and_authorize_resource :except => [:index]

  # GET /technologies
  # GET /technologies.json
  def index
    authorize! :manage_master_data, :all
    @technologies = Technology.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @technologies }
    end
  end

  # GET /technologies/1
  # GET /technologies/1.json
  def show
    authorize! :manage_master_data, :all

    @technology = Technology.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @technology }
    end
  end

  # GET /technologies/new
  # GET /technologies/new.json
  def new
    authorize! :manage_master_data, :all
    @technology = Technology.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @technology }
    end
  end

  # GET /technologies/1/edit
  def edit
    authorize! :manage_master_data, :all
    @technology = Technology.find(params[:id])
  end

  # POST /technologies
  # POST /technologies.json
  def create
    authorize! :manage_master_data, :all
    @technology = Technology.new(params[:technology])

    respond_to do |format|
      if @technology.save
        format.html { redirect_to @technology, notice: 'Technology was successfully created.' }
        format.json { render json: @technology, status: :created, location: @technology }
      else
        format.html { render action: "new" }
        format.json { render json: @technology.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /technologies/1
  # PUT /technologies/1.json
  def update
    authorize! :manage_master_data, :all
    @technology = Technology.find(params[:id])

    respond_to do |format|
      if @technology.update_attributes(params[:technology])
        format.html { redirect_to @technology, notice: 'Technology was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @technology.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /technologies/1
  # DELETE /technologies/1.json
  def destroy
    authorize! :manage_master_data, :all
    @technology = Technology.find(params[:id])
    @technology.destroy

    respond_to do |format|
      format.html { redirect_to technologies_url }
      format.json { head :no_content }
    end
  end
end
