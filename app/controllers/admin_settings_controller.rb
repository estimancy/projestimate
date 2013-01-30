#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012 Spirula (http://www.spirula.fr)
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

class AdminSettingsController < ApplicationController
  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  helper_method :admin_setting_selected_status

  def index
    set_page_title "Parameters"
    @admin_settings = AdminSetting.all
  end

  def new
    set_page_title "Parameters"
    @admin_setting = AdminSetting.new
  end

  def edit
    set_page_title "Parameters"
    @admin_setting = AdminSetting.find(params[:id])

    if is_master_instance?
      unless @admin_setting.child_reference.nil?
        if @admin_setting.child_reference.is_proposed_or_custom?
          flash[:notice] = "This administration setting record can not be edited, previous changes have not yet been validated."
          redirect_to admin_settings_path
        end
      end
    end
  end

  def create
    @admin_setting = AdminSetting.new(params[:admin_setting])

    unless is_master_instance?
      @admin_setting.record_status = @local_status
    end

    if @admin_setting.save
      flash[:notice] = 'Admin setting was successfully created.'
      redirect_to redirect(admin_settings_path)
    else
      render action: "new"
    end
  end


  def update
    @admin_setting = nil
    current_admin_setting = AdminSetting.find(params[:id])
    if current_admin_setting.is_defined? && is_master_instance?
      @admin_setting = current_admin_setting.amoeba_dup
      @admin_setting.owner_id = current_user.id
    else
      @admin_setting = current_admin_setting
    end

    unless is_master_instance?
      @admin_setting.custom_value = "Locally edited"
    end

    if @admin_setting.update_attributes(params[:admin_setting])
      flash[:notice] = 'Admin setting was successfully updated.'
      redirect_to redirect(admin_settings_path)
    else
      flash[:notice] = 'A error has occurred during the update.'
      render action: "edit"
    end
  end

  def destroy
    @admin_setting = AdminSetting.find(params[:id])
    if @admin_setting.is_local? and User.local_instance?
      @admin_setting.destroy
      flash[:notice] = 'Admin setting was successfully deleted.'
    else
      if @admin_setting.is_defined? || @admin_setting.is_custom?
        #logical deletion: delete don't have to suppress records anymore on defined record
        @admin_setting.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
        flash[:notice] = 'Admin setting was successfully updated.'
      else
        @admin_setting.destroy
        flash[:notice] = 'Admin setting was successfully deleted.'
      end
      flash[:notice] = "You can't delete this record"
    end

    redirect_to admin_settings_path
  end

  def admin_setting_selected_status
    begin
      selected = nil
      @admin_setting = AdminSetting.find(params[:id])  unless params[:id].nil?

      if is_master_instance?
        if @admin_setting.record_status.nil?  || @admin_setting.is_defined?
          selected = @proposed_status
        else
          selected = @admin_setting.record_status
        end
      else
        if  @admin_setting.record_status.nil? || @admin_setting.is_local_record?
          selected = @local_status
        else
          selected = @admin_setting.record_status
        end
      end

      selected

    rescue
      nil
    end
  end


  def unselect_conditions
    (@admin_setting.is_retired? || !is_master_instance?) ? "unselectable" : ""
  end

end
