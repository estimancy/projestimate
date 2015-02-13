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

class WorkElementTypesController < ApplicationController
  #include DataValidationHelper #Module for master data changes validation

  #before_filter :get_record_statuses

  load_resource

  def new
    authorize! :manage, WorkElementType
    set_page_title 'Work Element Type'
    @work_element_type = WorkElementType.new
    @organization = Organization.find(params[:organization_id])
  end

  # GET /work_element_types/1/edit
  def edit
    authorize! :manage, WorkElementType
    set_page_title 'Work Element Type'
    @work_element_type = WorkElementType.find(params[:id])
    @organization = Organization.find(params[:organization_id])

    unless @work_element_type.child_reference.nil?
      if @work_element_type.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_work_element_type_cant_be_edit)
        redirect_to edit_organization_path(@work_element_type.organization)
      end
    end
  end

  def create
    authorize! :manage, WorkElementType
    @work_element_type = WorkElementType.new(params[:work_element_type])
    @organization = @work_element_type.organization

    if @work_element_type.save
      flash[:notice] = I18n.t(:notice_work_element_type_successful_created)
      redirect_to redirect_apply(nil, new_organization_work_element_type_path(@organization), edit_organization_path(@organization, :anchor => 'settings'))
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage, WorkElementType
    @work_element_type = nil
    current_work_element_type = WorkElementType.find(params[:id])
    if current_work_element_type.is_defined?
      @work_element_type = current_work_element_type.amoeba_dup
      @work_element_type.owner_id = current_user.id
    else
      @work_element_type = current_work_element_type
    end

    if @work_element_type.update_attributes(params[:work_element_type])
      flash[:notice] =  I18n.t(:notice_work_element_type_successful_updated)
      redirect_to redirect_apply(nil, new_organization_path(@work_element_type.organization), edit_organization_path(@work_element_type.organization))
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, WorkElementType
    @work_element_type = WorkElementType.find(params[:id])
    organization_id = @work_element_type.organization
    if @work_element_type.is_defined? || @work_element_type.is_custom?
      #logical deletion: delete don't have to suppress records anymore
      @work_element_type.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
    else
      @work_element_type.destroy
    end

    redirect_to edit_organization_path(organization_id, anchor: "settings")
  end
end
