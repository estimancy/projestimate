class ProfilesController < ApplicationController

  include DataValidationHelper #Module for master data changes validation
  load_resource

  before_filter :get_record_statuses

  # GET /profiles
  # GET /profiles.json
  def index
    authorize! :manage_master_data, :all

    @profiles = Profile.all
  end

  # GET /profiles/new
  # GET /profiles/new.json
  def new
    authorize! :manage_master_data, :all

    @profile = Profile.new
    @profile_categories = ProfileCategory.defined.all
  end

  # GET /profiles/1/edit
  def edit
    authorize! :manage_master_data, :all

    set_page_title 'Edit profile'
    @profile = Profile.find(params[:id])
    @profile_categories = ProfileCategory.defined.all

    unless @profile.child_reference.nil?
      if @profile.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_profile_cant_be_edit)
        redirect_to profiles_path
      end
    end

  end

  # POST /profiles
  # POST /profiles.json
  def create
    authorize! :manage_master_data, :all

    set_page_title 'Create profile'

    @profile = Profile.new(params[:profile])
    @profile.owner_id = current_user.id
    @profile_categories = ProfileCategory.defined.all

    @profile.record_status = @proposed_status
    if @profile.save
      flash[:notice] = I18n.t (:notice_profile_successful_created)
      redirect_to redirect_apply(nil, new_profile_path(), profiles_path)
    else
      render action: 'new'
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.json
  def update
    authorize! :manage_master_data, :all

    set_page_title 'Update profile'
    @profile_categories = ProfileCategory.defined.all

    @profile = nil
    current_profile = Profile.find(params[:id])
    if current_profile.is_defined?
      @profile = current_profile.amoeba_dup
      @profile.owner_id = current_user.id
    else
      @profile = current_profile
    end

    if @profile.update_attributes(params[:profile])
      flash[:notice] = I18n.t (:notice_profile_successful_updated)
      redirect_to redirect_apply(edit_profile_path(@profile), nil, profiles_path)
    else
      flash[:error] = I18n.t(:error_profile_failed_update)
      render action: 'edit'
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    authorize! :manage_master_data, :all

    set_page_title 'Delete profile'
    @profile = Profile.find(params[:id])

    if @profile.is_custom?
      #logical deletion  delete don't have to suppress records anymore on Defined record
      @profile.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
      flash[:notice] = I18n.t (:notice_profile_successful_deleted)
    elsif @profile.is_defined?
      flash[:warning] = I18n.t(:defined_profile_not_deletable)
    else
      @profile.destroy
      flash[:notice] = I18n.t (:notice_profile_successful_deleted)
    end

    respond_to do |format|
      format.html { redirect_to profiles_url }
      format.json { head :no_content }
    end
  end

end