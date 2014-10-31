#encoding: utf-8
#########################################################################
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
#    ===================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012-2013 Spirula (http://www.spirula.fr)
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
########################################################################

class GroupsController < ApplicationController
  load_resource
  helper_method :enable_update_in_local?

  def index
    if (can? :create_and_edit_groups, Group) || (can? :manage, User)
      set_page_title 'Groups'
      @groups = Group.all
    end
  end

  def new
    authorize! :create_and_edit_groups, Group

    set_page_title 'New group'
    @group = Group.new
    @organization = Organization.find_by_id(params[:organization_id])
    @users = User.all
    @projects = Project.all.reject { |i| !i.is_childless? }
    @enable_update_in_local = true
  end

  def edit
    set_page_title 'Edit group'
    @group = Group.find(params[:id])
    @users = User.all
    @projects = Project.all.reject { |i| !i.is_childless? }
    @organization = @group.organization
  end

  def create
    authorize! :create_and_edit_groups, Group

    @users = User.all
    @projects = Project.all.reject { |i| !i.is_childless? }
    @group = Group.new(params[:group])
    @enable_update_in_local = true
    @organization = Organization.find_by_id(params['group']['organization_id'])

    #If we are on local instance, Status is set to "Local"
    if is_master_instance? && @organization.nil?
      @group.record_status = @proposed_status
    else
      @group.record_status = @local_status
    end

    if @group.save
      redirect_to redirect_apply(edit_group_path(@group, :anchor => session[:anchor]), new_group_path(), groups_path())
    else
      render action: 'new'
    end
  end

  #Update the selected users in the group's securities
  def update_selected_users
    authorize! :manage, User

    @group = Group.find(params[:group_id])
    user_ids = params[:group][:user_ids]

    @group.users.each do |u|
      gu = GroupsUsers.where(:group_id => @group.id, :user_id => u.id) unless u.blank?
      gu.delete_all
    end

    user_ids.each do |u|
      gu = GroupsUsers.create(:group_id => @group.id, :user_id => u)
    end

    @group.projects(force_reload = true)

    if @group.save
      flash[:notice] = I18n.t(:notice_group_successful_updated)
    else
      flash[:notice] = I18n.t(:error_group_failed_update)
    end

    redirect_to redirect(groups_path)
  end

  # #Update the selected users in the project's securities
  def update_selected_projects
    authorize! :manage, User

    @group = Group.find(params[:group_id])
    project_ids = params[:group][:project_ids]

    @group.projects.each do |p|
      gp = GroupsProjects.where(:group_id => @group.id, :project_id => p.id)
      gp.delete_all
    end

    project_ids.each do |g|
      GroupsProjects.create(:group_id => @group.id, :project_id => g) unless g.blank?
    end

    @group.projects(force_reload = true)

    if @group.save
      flash[:notice] = I18n.t(:notice_group_successful_updated)
    else
      flash[:notice] = I18n.t(:error_group_failed_update)
    end

    redirect_to redirect(groups_path)
  end


  def update
    authorize! :create_and_edit_groups, Group

    @users = User.all
    @projects = Project.all.reject { |i| !i.is_childless? }
    @group = Group.find(params[:id])
    @organization = @group.organization

    if @group.update_attributes(params[:group])
      #redirect_to redirect(groups_path), :notice => "#{I18n.t (:notice_group_successful_updated)}"
      flash[:notice] =  "#{I18n.t (:notice_group_successful_updated)}"
      redirect_to edit_organization_path(@organization)
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, User

    @group = Group.find(params[:id])
    @organization = @group.organization
    @group.destroy

    flash[:notice] = I18n.t (:notice_group_successful_deleted)
    redirect_to groups_url
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
        @group = Group.find(params[:id])
        if @group.is_local_record?
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
