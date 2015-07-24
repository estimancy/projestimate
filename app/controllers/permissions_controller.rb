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
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

class PermissionsController < ApplicationController

  load_resource

  def index
    authorize! :manage_master_data, :all

    set_page_title 'Permissions'
    @permissions = Permission.all

    respond_to do |format|
      format.html
    end
  end

  def new
    authorize! :manage_master_data, :all

    set_page_title 'Permissions'
    @permission = Permission.new
  end

  def edit
    authorize! :manage_master_data, :all

    set_page_title 'Permissions'
    @permission = Permission.find(params[:id])
  end

  def create
    authorize! :manage_master_data, :all

    @permission = Permission.new(params[:permission])

    @groups = Group.all

    @permission.alias = params[:permission][:alias].underscore.gsub(' ', '_')

    if @permission.save
      redirect_to redirect_apply(nil, new_permission_path(), session[:previous] + "#authorizations"), notice: "#{I18n.t (:notice_permission_successful_created)}"
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage_master_data, :all

    @permission = Permission.find(params[:id])

    if @permission.update_attributes(params[:permission])
      @permission.alias = @permission.alias.underscore.gsub(' ', '_')
      @permission.save
      redirect_to session[:previous] + "#authorizations"
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage_master_data, :all
    @permission = Permission.find(params[:id])
    @permission.destroy
    redirect_to permissions_path, notice: "#{I18n.t (:notice_permission_successful_deleted)}"
  end

  #Set all global rights : organization and modules permissions
  def set_rights
    authorize! :manage_organization_permissions, Permission

    if params[:organization_permissions] == I18n.t('cancel') || params[:modules_permissions] == I18n.t('cancel')
      flash[:notice] = I18n.t(:notice_permission_successful_cancelled)
    else
      @groups = @current_organization.groups
      @permissions = Permission.defined

      @groups.each do |group|
        group.update_attribute('permission_ids', params[:permissions][group.id.to_s])
      end
    end

    redirect_tab = "tabs-global-permissions"
    if !params[:modules_permissions].nil?
      redirect_tab = "tabs-modules-permissions"
    elsif !params[:organization_permissions].nil?
      redirect_tab = "tabs-organization-permissions"
    end
    redirect_to organization_authorization_path(@current_organization, anchor: redirect_tab)
  end

  #Set rights on estimations permissions
  def set_rights_project_security
    authorize! :manage_estimations_permissions, Permission

    @organization = Organization.find(params[:organization_id])
    #For the cancel button
    if params[:commit] == I18n.t('cancel')
      redirect_to organization_authorization_path(@organization, :anchor => "tabs-estimations-permissions"), :notice => "#{I18n.t (:notice_permission_successful_cancelled)}"
    else
      @project_security_levels = @organization.project_security_levels
      @permissions = Permission.defined

      @project_security_levels.each do |psl|
        if params[:permissions].nil?
          psl.update_attribute('permission_ids', nil)
        else
          psl.update_attribute('permission_ids', params[:permissions][psl.id.to_s])
        end
      end

      redirect_to organization_authorization_path(@organization, anchor: "tabs-estimations-permissions")
    end
  end
end
