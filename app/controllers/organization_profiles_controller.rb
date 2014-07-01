class OrganizationProfilesController < ApplicationController

  # GET /organization_profiles/new
  # GET /organization_profiles/new.json
  def new
    authorize! :create_and_edit_organizations, Organization
    set_page_title 'New organization profile'
    @organization = Organization.find_by_id(params[:organization_id])
    @organization_profile = OrganizationProfile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @organization_profile }
    end
  end

  # GET /organization_profiles/1/edit
  def edit
    authorize! :create_and_edit_organizations, Organization
    set_page_title 'Edit organization profile'
    @organization_profile = OrganizationProfile.find(params[:id])
    @organization = @organization_profile.organization
  end

  # POST /organization_profiles
  # POST /organization_profiles.json
  def create
    authorize! :create_and_edit_organizations, Organization
    set_page_title 'Create organization profile'

    @organization_profile = OrganizationProfile.new(params[:organization_profile])
    @organization = Organization.find_by_id(params['organization_profile']['organization_id'])

    respond_to do |format|
      if @organization_profile.save
        format.html { redirect_to edit_organization_path(@organization, anchor: 'tabs-13'), notice: I18n.t(:notice_profile_successful_created) }
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
    authorize! :create_and_edit_organizations, Organization
    set_page_title 'Update organization profile'

    @organization_profile = OrganizationProfile.find(params[:id])
    @organization = @organization_profile.organization

    respond_to do |format|
      if @organization_profile.update_attributes(params[:organization_profile])
        format.html { redirect_to edit_organization_path(@organization, anchor: 'tabs-13'), notice: I18n.t(:notice_profile_successful_updated) }
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
    authorize! :manage, Organization
    set_page_title 'Delete organization profile'

    @organization_profile = OrganizationProfile.find(params[:id])
    @organization = @organization_profile.organization
    @organization_profile.destroy

    respond_to do |format|
      format.html { redirect_to edit_organization_path(@organization, anchor: 'tabs-13') }
      format.json { head :no_content }
    end
  end
end
