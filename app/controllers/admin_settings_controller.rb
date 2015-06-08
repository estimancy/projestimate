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
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
########################################################################

class AdminSettingsController < ApplicationController
  include DataValidationHelper #Module for master data changes validation
  load_resource

  before_filter :get_record_statuses

  helper_method :admin_setting_selected_status

  def maintenances
    @admin_setting = AdminSetting.where(key: "allow_authentication").first
  end

  def mass_mailing
    @users = User.all
    @message = params[:message]
    @objet = params[:objet]
    UserMailer.maintenance(@users, @message, @objet).deliver
    redirect_to "/organizationals_params"
  end

  def index
    authorize! :manage_master_data, :all

    set_page_title 'Parameters'
    @admin_settings = AdminSetting.all
  end

  def new
    authorize! :manage_master_data, :all

    set_page_title 'Parameters'
    @admin_setting = AdminSetting.new
  end

  def edit
    authorize! :manage_master_data, :all

    set_page_title 'Parameters'
    @admin_setting = AdminSetting.find(params[:id])

    if is_master_instance?
      unless @admin_setting.child_reference.nil?
        if @admin_setting.child_reference.is_proposed_or_custom?
          flash[:warning] = I18n.t (:warning_administration_setting_cant_be_edited)
          redirect_to admin_settings_path
        end
      end
    end
  end

  def create
    authorize! :manage_master_data, :all

    @admin_setting = AdminSetting.new(params[:admin_setting])

    unless is_master_instance?
      @admin_setting.record_status = @local_status
    end

    if @admin_setting.save
      flash[:notice] = I18n.t (:notice_administration_setting_successful_created)
      redirect_to redirect_apply(nil,new_admin_setting_path(),admin_settings_path)
    else
      render action: 'new'
    end
  end


  def update
    authorize! :manage_master_data, :all

    @admin_setting = nil
    current_admin_setting = AdminSetting.find(params[:id])
    if current_admin_setting.is_defined? && is_master_instance?
      @admin_setting = current_admin_setting.amoeba_dup
      @admin_setting.owner_id = current_user.id
    else
      @admin_setting = current_admin_setting
    end

    unless is_master_instance?
      @admin_setting.custom_value = 'Locally edited'
    end

    if @admin_setting.update_attributes(params[:admin_setting])
      flash[:notice] = I18n.t (:notice_administration_setting_successful_updated)
      redirect_to redirect_apply(edit_admin_setting_path(@admin_setting),nil,admin_settings_path)
    else
      flash[:error] = I18n.t (:error_administration_setting_failed_update)
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage_master_data, :all

    @admin_setting = AdminSetting.find(params[:id])

    if is_master_instance?
      if @admin_setting.is_defined? || @admin_setting.is_custom?
        #logical deletion: delete don't have to suppress records anymore on defined record
        @admin_setting.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
        flash[:notice] = I18n.t (:notice_administration_setting_successful_deleted)
      else
        @admin_setting.destroy
        flash[:notice] = I18n.t (:notice_administration_setting_successful_deleted)
      end
      #if in local instance
    else
      if @admin_setting.is_local_record?
        @admin_setting.destroy
        flash[:notice] = I18n.t (:notice_administration_setting_successful_deleted)
      else
        flash[:warning] = I18n.t (:warning_masterdata_record_cant_delete)
      end
    end

    redirect_to admin_settings_path
  end

protected

  def admin_setting_selected_status
    begin
      #No authorize required since this method is protected and won't be call from any route
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

end
