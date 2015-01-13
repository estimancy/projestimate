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
#   ======================================================================
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
#############################################################################

class AcquisitionCategoriesController < ApplicationController
  #include DataValidationHelper #Module for master data changes validation
  #before_filter :get_record_statuses

  load_resource

  def new
    authorize! :manage, AcquisitionCategory

    set_page_title I18n.t (:acquisition_category)
    @acquisition_category = AcquisitionCategory.new
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    #no authorize required since everyone can show this object
    set_page_title I18n.t (:acquisition_category)
    @acquisition_category = AcquisitionCategory.find(params[:id])
    @organization = Organization.find(params[:organization_id])

    unless @acquisition_category.child_reference.nil?
      if @acquisition_category.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_acquisition_category_cannot_be_updated)
        redirect_to redirect(projects_global_params_path(:anchor => "tabs-4"))
      end
    end
  end

  def create
    authorize! :manage, AcquisitionCategory

    @acquisition_category = AcquisitionCategory.new(params[:acquisition_category])
    @organization = Organization.find(params[:organization_id])

    if @acquisition_category.save
      flash[:notice] = I18n.t (:notice_acquisition_category_successful_created)
      redirect_to redirect_apply(nil, new_organization_acquisition_category_path(@organization), edit_organization_path(@organization))
    else
      render action: "edit"
    end
  end

  def update
    authorize! :manage, AcquisitionCategory

    @organization = Organization.find(params[:organization_id])
    @acquisition_category = nil
    current_acquisition_category = AcquisitionCategory.find(params[:id])
    if current_acquisition_category.record_status == @defined_status
      @acquisition_category = current_acquisition_category.amoeba_dup
      @acquisition_category.owner_id = current_user.id
    else
      @acquisition_category = current_acquisition_category
    end

    if @acquisition_category.update_attributes(params[:acquisition_category])
      flash[:notice] = I18n.t (:notice_acquisition_category_successful_updated)
      redirect_to redirect_apply(nil, new_organization_acquisition_category_path(@organization), edit_organization_path(@organization))
    else
      render action: "edit"
    end
  end

  def destroy
    authorize! :manage, AcquisitionCategory

    @acquisition_category = AcquisitionCategory.find(params[:id])
    organization_id = @acquisition_category.organization_id
    if @acquisition_category.is_defined? || @acquisition_category.is_custom?
      #logical deletion: delete don't have to suppress records anymore on Defined record
      @acquisition_category.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
    else
      #physical deletion when record is not defined
      @acquisition_category.destroy
    end

    flash[:notice] = I18n.t (:notice_acquisition_category_successful_destroyed)
    redirect_to edit_organization_path(organization_id, :anchor => "tabs-acquisition-categories")
  end
end
