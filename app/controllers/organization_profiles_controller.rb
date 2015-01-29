class OrganizationProfilesController < ApplicationController

  # GET /organization_profiles/new
  # GET /organization_profiles/new.json
  def new
    authorize! :manage, OrganizationProfile

    set_page_title 'New organization profile'
    @organization = Organization.find_by_id(params[:organization_id])
    @organization_profile = OrganizationProfile.new
    @profile_categories = (ProfileCategory.defined + @organization.profile_categories.all).flatten
  end

  # GET /organization_profiles/1/edit
  def edit
    authorize! :manage, OrganizationProfile

    set_page_title 'Edit organization profile'
    @organization_profile = OrganizationProfile.find(params[:id])
    @organization = @organization_profile.organization
    @profile_categories = (ProfileCategory.defined + @organization.profile_categories.all).flatten
  end

  # POST /organization_profiles
  # POST /organization_profiles.json
  def create
    authorize! :manage, OrganizationProfile
    set_page_title 'Create organization profile'

    @organization_profile = OrganizationProfile.new(params[:organization_profile])
    @organization = Organization.find_by_id(params['organization_profile']['organization_id'])
    @profile_categories = (ProfileCategory.defined + @organization.profile_categories.all).flatten

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

  # PUT /organization_profiles/1
  # PUT /organization_profiles/1.json
  def update
    authorize! :manage, OrganizationProfile
    set_page_title 'Update organization profile'

    @organization_profile = OrganizationProfile.find(params[:id])
    @organization = @organization_profile.organization
    @profile_categories = (ProfileCategory.defined + @organization.profile_categories.all).flatten

    respond_to do |format|
      if @organization_profile.update_attributes(params[:organization_profile])
        format.html { redirect_to edit_organization_path(@organization, anchor: 'tabs-profile'), notice: I18n.t(:notice_profile_successful_updated) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @organization_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organization_profiles/1
  # DELETE /organization_profiles/1.json
  def destroy
    authorize! :manage, OrganizationProfile
    set_page_title 'Delete organization profile'

    @organization_profile = OrganizationProfile.find(params[:id])
    @organization = @organization_profile.organization
    @organization_profile.destroy

    respond_to do |format|
      format.html { redirect_to edit_organization_path(@organization, anchor: 'tabs-profile') }
      format.json { head :no_content }
    end
  end

  def refresh_organization_profiles
    if !params[:profile_category_id].nil?
      @profile_category = ProfileCategory.find(params[:profile_category_id])
      @profiles = @profile_category.profiles
    end
    #Voir si il faut modifier le cout horaire lorsqu'on change de profile
  end

  def refresh_organization_profile_data
    @profile_name = nil; @profile_description = nil; @profile_cost_per_hour= nil
    if !params[:profile_id].nil?
      @profile_for_organization = Profile.find(params[:profile_id])
      @profile_name = @profile_for_organization.name
      @profile_description = @profile_for_organization.description
      @profile_cost_per_hour = @profile_for_organization.cost_per_hour
    end
  end

end
