#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    ======================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2013 Spirula (http://www.spirula.fr)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

class UsersController < ApplicationController
  require 'securerandom'

  #before_filter :verify_authentication, :except => [:show, :create_inactive_user]
  before_filter :load_data, :only => [:update, :edit, :new, :create, :create_inactive_user]
  #load_and_authorize_resource :except => [:edit, :show, :update, :create_inactive_user]
  load_resource

protected

  def load_data
    #No authorize required since this method is protected and won't be call from any route
    if params[:id]
      @user = User.find(params[:id])
    else
      @user = User.new
      @user.auth_type = AuthMethod.first.id
    end
  end

public

  def index
    #authorize! :manage, User
    #all users menu/page is only visible by master users
    authorize! :manage_master_data, :all

    set_page_title 'Users'
    @users = User.all
    @audits = Audit.all
  end

  def new
    authorize! :manage, User

    set_page_title 'New user'
    set_breadcrumbs "Organizations" => "/organizationals_params", @current_organization => "#!", I18n.t(:new_user) => ""

    @organization_id = params[:organization_id]
    unless @organization_id.nil? || @organization_id.empty?
      @organization = Organization.find_by_id(params[:organization_id])
      @user_group = @organization.groups.where(name: '*USER').first_or_create(organization_id: @organization.id, name: "*USER")
    end

    @user = User.new
    @user.auth_type = AuthMethod.first.id
    @generated_password = SecureRandom.hex(4)
    @organizations = current_user.organizations
  end

  def create
    authorize! :manage, User

    set_page_title 'New user'

    unless @organization_id.nil? || @organization_id.empty?
      @organization = Organization.find_by_id(params[:organization_id])
      @user_group = @organization.groups.where(name: '*USER').first_or_create(organization_id: @organization.id, name: "*USER")
      @user.groups << @user_group
    end

    @user = User.new(params[:user])
    @user.auth_type = params[:user][:auth_type]
    @user.language_id = params[:user][:language_id]
    @user.project_ids = params[:user][:project_ids]
    @user.organization_ids = params[:user][:organization_ids]

    unless params[:groups].nil?
      @user.group_ids = params[:groups].keys
      @user.save
    end

    if @user.save
      flash[:notice] = I18n.t(:notice_account_successful_created)
      if @organization.nil?
        redirect_to redirect_apply(edit_user_path(@user), new_user_path(:anchor => 'tabs-1'), users_path) and return
      else
        user_first_organization = OrganizationsUsers.new(organization_id: @organization.id, user_id: @user.id)
        user_first_organization.save
        redirect_to redirect_apply(edit_user_path(@user), new_user_path(:anchor => 'tabs-1'), organization_users_path(@organization_id)) and return
      end

    else
      render(:new, organization_id: @organization_id)
    end
  end

  def edit

    set_breadcrumbs "Organizations" => "/organizationals_params", @current_organization => "#!", I18n.t(:new_user) => ""

    @user = User.find(params[:id])

    if params[:organization_id].present?
      @organization = Organization.find(params[:organization_id])
    end

    if current_user == @user
      set_page_title 'Edit your user account'
    else
      authorize! :show_organization_users, User
    end
  end


  #Update user
  def update
    @user = User.find(params[:id])
    if current_user != @user
      authorize! :manage, User
    end

    set_page_title 'Edit user'

    #Get the current organization
    @organization_id = params[:organization_id]
    unless @organization_id.nil? || @organization_id.empty?
      @organization = Organization.find(params[:organization_id])
    end

    unless params[:groups].nil?
      @user.group_ids = params[:groups].keys
      @user.save
    else
      @user.group_ids = []
      @user.save
    end

    unless params[:organizations].nil?
      @user.organization_ids = params[:organizations].keys
      @user.save
    else
      @user.organization_ids = []
      @user.save
    end

    # Get the Application authType
    application_auth_type = AuthMethod.where('name = ? AND record_status_id =?', 'Application', @defined_record_status.id).first

    if application_auth_type && params[:user][:auth_type].to_i != application_auth_type.id
      params[:user].delete :password
      params[:user].delete :password_confirmation
    end

    @user.auth_type = params[:user][:auth_type]
    @user.language_id = params[:user][:language_id]

    #validation conditions
    if params[:user][:password].blank?
      # User is not updating his password
      @user.updating_password = false
    else
      # User is updating his password
      @user.updating_password = true
    end

    successfully_updated = if @user.updating_password
                             @user.update_with_password(params[:user])
                           else
                             params[:user].delete(:current_password)
                             @user.update_without_password(params[:user])
                           end

    if successfully_updated
      set_user_language
      flash[:notice] = I18n.t (:notice_account_successful_updated)
      @user_current_password = nil;  @user_password = nil; @user_password_confirmation = nil
      if @organization.nil?
        redirect_to redirect_apply(edit_organization_user_path(@user), new_user_path(:anchor => 'tabs-1'), users_path) and return
      else
        redirect_to redirect_apply(edit_organization_user_path(@organization, @user), new_user_path(:anchor => 'tabs-1'), organization_users_path(@organization))
      end

    else
      @user_current_password = params[:user][:current_password];  @user_password = params[:user][:password]; @user_password_confirmation = params[:user][:password_confirmation]
      render(:edit, organization_id: @organization_id)
    end
  end

  #Create a inactive user if the demand is ok.
  def create_inactive_user
    #No authorize required since everyone can ask for new account which will be validated by an Admin

    unless (params[:email].blank? || params[:first_name].blank? || params[:last_name].blank? || params[:login_name].blank?)
      user = User.where('login_name = ? OR email = ?', params[:login_name], params[:email]).first
      is_an_automatic_account_activation? ? status = 'active' : status = 'pending'

      if !user.nil?
        redirect_to :back, :flash => {:warning => "#{I18n.t (:warning_email_or_username_already_exist)}"}
      else
        user = User.new(:email => params[:email],
                        :first_name => params[:first_name],
                        :last_name => params[:last_name],
                        :login_name => params[:login_name],
                        :language_id => params[:language],
                        :initials => 'your_initials',
                        :auth_type => AuthMethod.find_by_name('Application').id)

        user.password = Standards.random_string(8)

        user.group_ids = [Group.last.id]

        user.save(:validate => false)

        UserMailer.account_created(user).deliver
        if !user.active?
          UserMailer.account_request(@defined_record_status).deliver
          redirect_to :back, :notice => "#{I18n.t (:ask_new_account_help)}"
        else
          UserMailer.account_validate(user).deliver
          redirect_to :back, :notice => "#{I18n.t (:notice_account_successful_created)}, #{I18n.t(:ask_new_account_help2)}"
        end
      end
    else
      redirect_to :back, :flash => {:warning => "#{I18n.t (:warning_check_all_fields)}"}
    end
  end

  def destroy
    authorize! :manage, User

    @user = User.find(params[:id])
    @user.destroy

    if params[:organization_id]
      redirect_to organization_users_path(organization_id: params[:organization_id]) and return
    elsif current_user.super_admin?
      redirect_to users_path and return
    else
      redirect_to :back
    end
  end

  def find_use_user
    # No authorize required since everyone can find use for a user
    @user = User.find(params[:user_id])
    #@related_projects = @user.projects
    #Direct access project with Permissions
    @related_projects_securities = @user.project_securities

    #Indirect acceded project via groups
    @user.groups.each do |user_group|
      @related_projects_securities += user_group.project_securities
    end
    @related_projects_securities.sort_by(&:project_id)
  end

  def about
    # No authorize required since everyone can access the about page
    set_page_title 'About'
    latest_record_version = Version.last.nil? ? Version.create(:comment => 'No update data has been save') : Version.last
    @latest_repo_update = latest_record_version.repository_latest_update #Home::latest_repo_update
    @latest_local_update = latest_record_version.local_latest_update
    Rails.cache.write('latest_update', @latest_local_update)
  end

  def display_states
    #No authorize required since this method is not used since now
    @users = User.page(params[:page])
  end

  def send_feedback
    # No authorize required since everyone can send a feedback if the feature have been enabled using the allow_feedback admin settings.
    latest_record_version = Version.last.nil? ? Version.create(:comment => 'No update data has been save') : Version.last
    @latest_repo_update = latest_record_version.repository_latest_update #Home::latest_repo_update
    @latest_local_update = latest_record_version.local_latest_update
    @projestimate_version=projestimate_version
    @ruby_version=ruby_version
    @rails_version=rails_version
    @environment=environment
    @database_adapter=database_adapter
    @browser=browser
    @version_browser=version_browser
    @platform=platform
    @os=os
    @server_name=server_name
    @root_url =root_url
    um = UserMailer.send_feedback(params[:send_feedback][:user_name],
                                  params[:send_feedback][:type],
                                  params[:send_feedback][:description],
                                  @latest_repo_update,
                                  @projestimate_version,
                                  @ruby_version,
                                  @rails_version,
                                  @environment,
                                  @database_adapter, @browser, @version_browser, @platform, @os, @server_name, @root_url, @defined_record_status)
    if um.deliver
      flash[:notice] = I18n.t (:notice_send_feedback_success)
      redirect_to session[:return_to]
    else
      flash[:error] = I18n.t (:error_send_feedback_failed)
    end

  end

  protected
  def is_an_automatic_account_activation?
    #No authorize required since this method is protected and won't be call from any route
    AdminSetting.where(:record_status_id => RecordStatus.find_by_name('Defined').id, :key => 'self-registration').first.value == 'automatic account activation'
  end

end
