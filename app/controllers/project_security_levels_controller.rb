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

class ProjectSecurityLevelsController < ApplicationController
  include DataValidationHelper #Module for master data changes validation
  load_resource

  before_filter :get_record_statuses

  def index
    authorize! :manage, ProjectSecurityLevel

    set_page_title 'Project security levels'
    @project_security_levels = ProjectSecurityLevel.all
  end

  def new
    authorize! :manage, ProjectSecurityLevel

    set_page_title 'Project security levels'
    @project_security_level = ProjectSecurityLevel.new
  end

  def edit
    authorize! :manage, ProjectSecurityLevel

    set_page_title 'Project security levels'

    @project_security_level = ProjectSecurityLevel.find(params[:id])

    unless @project_security_level.child_reference.nil?
      if @project_security_level.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_project_securities_level_cant_be_edit)
        redirect_to project_security_levels_path
      end
    end
  end

  def create
    authorize! :manage, ProjectSecurityLevel

    @project_security_level = ProjectSecurityLevel.new(params[:project_security_level])

    if @project_security_level.save
      redirect_to redirect(project_security_levels_url), notice: "#{I18n.t (:notice_project_securities_level_successful_created)}"
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage, ProjectSecurityLevel

    @project_security_level = nil
    current_project_security_level = ProjectSecurityLevel.find(params[:id])
    if current_project_security_level.is_defined?
      @project_security_level = current_project_security_level.amoeba_dup
      @project_security_level.owner_id = current_user.id
    else
      @project_security_level = current_project_security_level
    end

    if @project_security_level.update_attributes(params[:project_security_level])
      redirect_to redirect(project_security_levels_url), notice: "#{I18n.t (:notice_project_securities_level_successful_updated)}"
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, ProjectSecurityLevel

    @project_security_level = ProjectSecurityLevel.find(params[:id])
    if @project_security_level.is_defined? || @project_security_level.is_custom?
      #logical deletion: delete don't have to suppress records anymore
      @project_security_level.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
    else
      @project_security_level.destroy
    end

    respond_to do |format|
      format.html { redirect_to project_security_levels_url, notice: "#{I18n.t (:notice_project_securities_level_successful_deleted)}" }
    end
  end
end
