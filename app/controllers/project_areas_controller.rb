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

class ProjectAreasController < ApplicationController
  include DataValidationHelper #Module for master data changes validation

  load_resource

  before_filter :get_record_statuses
  before_filter :get_associations_records, :only => [:new, :edit, :create, :update]

  def get_associations_records
    #no authorize required since everyone can show this object
    @acquisition_categories = AcquisitionCategory.all
    @platform_categories = PlatformCategory.all
    @project_categories = ProjectCategory.all
  end

  def new
    authorize! :manage, ProjectArea

    set_page_title 'Project Area'
    @project_area = ProjectArea.new
  end

  def edit
    #no authorize required since everyone can show this object
    set_page_title 'Project Area'
    @project_area = ProjectArea.find(params[:id])

    unless @project_area.child_reference.nil?
      if @project_area.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_project_area_cant_be_edit)
        redirect_to redirect(projects_global_params_path(:anchor => 'tabs-1'))
      end
    end
  end

  def create
    authorize! :manage, ProjectArea

    @project_area = ProjectArea.new(params[:project_area])
    @project_area.owner_id = current_user.id

    if @project_area.save
      flash[:notice] = I18n.t (:notice_project_area_successful_created)
      redirect_to redirect_apply(nil,new_project_area_path(), projects_global_params_path(:anchor => 'tabs-1') )
    else
       render action: 'new'
    end
  end

  def update
    authorize! :manage, ProjectArea

    @project_area = nil
    current_project_area = ProjectArea.find(params[:id])
    if current_project_area.is_defined?
      @project_area = current_project_area.amoeba_dup
      @project_area.owner_id = current_user.id
    else
      @project_area = current_project_area
    end

    if @project_area.update_attributes(params[:project_area])
      flash[:notice] = I18n.t (:notice_project_area_successful_updated)
      redirect_to redirect_apply(edit_project_area_path(@project_area), nil, projects_global_params_path(:anchor => 'tabs-1') )
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, ProjectArea

    @project_area = ProjectArea.find(params[:id])
    if @project_area.is_defined? || @project_area.is_custom?
      #logical deletion: delete don't have to suppress records anymore if record status is defined
      @project_area.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
    else
      @project_area.destroy
    end

    flash[:notice] = I18n.t (:notice_project_area_successful_deleted)
    redirect_to projects_global_params_path(:anchor => 'tabs-1')
  end
end
