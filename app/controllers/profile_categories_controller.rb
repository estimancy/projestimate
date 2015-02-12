class ProfileCategoriesController < ApplicationController

  include DataValidationHelper #Module for master data changes validation
  load_resource

  before_filter :get_record_statuses
  helper_method :enable_update_in_local?

  def index
    authorize! :show_profile_categories, ProfileCategory

    set_page_title 'Profile Categories'
    @profile_categories = ProfileCategory.all
  end

  def new
    authorize! :manage_master_data, :all

    set_page_title 'Profile Categories'
    @profile_category = ProfileCategory.new
    @enable_update_in_local = true

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @profile_categories }
    end
  end

  def edit
    authorize! :show_profile_categories, ProfileCategory

    set_page_title 'Edit profile Categories'
    @profile_category = ProfileCategory.find(params[:id])

    if is_master_instance?
      @enable_update_in_local = true
      unless @profile_category.child_reference.nil?
        if @profile_category.child_reference.is_proposed_or_custom?
          flash[:warning] = I18n.t (:warning_profile_category_cant_be_edit)
          redirect_to profile_categories_path and return
        end
      end
    else
      if @profile_category.is_local_record?
        @profile_category.record_status = @local_status
        @enable_update_in_local = true
        ##flash[:notice] = "testing"
      else
        @enable_update_in_local = false
        #  flash[:error] = "Master record can not be edited, it is required for the proper functioning of the application"
        #  redirect_to redirect(groups_path)
      end
    end

  end

  def create
    authorize! :manage_master_data, :all

    @profile_category = ProfileCategory.new(params[:profile_category])
    @profile_category.owner_id = current_user.id
    @enable_update_in_local = true

    #If we are on local instance, Status is set to "Local"
    if is_master_instance? && params[:profile_category][:organization_id].blank?
      @profile_category.record_status = @proposed_status
    else
      @profile_category.record_status = @local_status
    end

    if @profile_category.save
      flash[:notice] = I18n.t (:notice_profile_category_successful_created)
      if params[:profile_category][:organization_id]
        redirect_to edit_organization_path(@organization, anchor: 'tabs-profile')  ###redirect_to :back
      else
        redirect_to redirect_apply(nil, new_profile_category_path(), profile_categories_path)
      end
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage_master_data, :all

    @profile_category = nil
    current_profile_category = ProfileCategory.find(params[:id])

    if current_profile_category.is_defined? && is_master_instance?
      @enable_update_in_local = true
      @profile_category = current_profile_category.amoeba_dup
      @profile_category.owner_id = current_user.id
    else
      @profile_category = current_profile_category
    end

    if is_master_instance?
      @enable_update_in_local = true
    else
      if @profile_category.is_local_record?
        @enable_update_in_local = true
        @profile_category.custom_value = 'Locally edited'
      else
        @enable_update_in_local = false
      end
    end

    if @profile_category.update_attributes(params[:profile_category])
      flash[:notice] = I18n.t (:notice_profile_category_successful_updated)
      redirect_to redirect_apply(edit_profile_category_path(@profile_category), nil, profile_categories_path)
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage_master_data, :all

    @profile_category = ProfileCategory.find(params[:id])

    if is_master_instance?
      if @profile_category.is_defined? || @profile_category.is_custom?
        #logical deletion: delete don't have to suppress records anymore on defined record
        @profile_category.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
      else
        @profile_category.destroy
      end
    else
      if @profile_category.is_local_record? || @profile_category.is_retired?
        @profile_category.destroy
      else
        flash[:error] = I18n.t (:warning_master_record_cant_be_delete)
        redirect_to redirect(profile_categories_path) and return
      end
    end

    flash[:notice] = I18n.t (:notice_profile_category_successful_deleted)
    redirect_to profile_categories_path
  end

  # Create new profile category on the Organization profile path
  def new_profile_category_with_organization
    authorize! :manage_master_data, :all

    set_page_title 'Create organization profile category'

    @profile_category = ProfileCategory.new(params[:profile_category])
    @profile_category.owner_id = current_user.id
    @profile_category.organization_id = params['organization_id']

    @organization_id = params['organization_profile']['organization_id']

    respond_to do |format|
      if @organization_profile.save
        format.html { redirect_to edit_organization_path(@organization, anchor: 'tabs-profile'), notice: I18n.t(:notice_profile_successful_created) }
        format.json { render json: @organization_profile, status: :created, location: @organization_profile }
      else
        flash[:error] = I18n.t(:error_profile_failed_created)
        format.html { render action: "new" }
        format.json { render json: @organization_profile.errors, status: :unprocessable_entity }
      end
    end
  end


  protected

  def enable_update_in_local?
    #No authorize required since this method is protected and won't be call from route
    if is_master_instance?
      true
    else
      if params[:action] == 'new'
        true
      elsif params[:action] == 'edit'
        @profile_category = ProfileCategory.find(params[:id])
        if @profile_category.is_local_record?
          true
        else
          if params[:anchor] == 'tabs-1'
            false
          end
        end
      end
    end
  end

end
