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

class PlatformCategoriesController < ApplicationController
  #include DataValidationHelper #Module for master data changes validation

  load_resource

  #before_filter :get_record_statuses

  def new
    authorize! :manage, PlatformCategory

    set_page_title 'Platform Category'
    @platform_category = PlatformCategory.new
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    #no authorize required since everyone can show this object
    set_page_title 'Platform Category'
    @platform_category = PlatformCategory.find(params[:id])
    @organization = Organization.find(params[:organization_id])

    unless @platform_category.child_reference.nil?
      if @platform_category.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_platform_category_cant_be_edit)
        redirect_to redirect(edit_organization_path(:anchor => 'tabs-platform-categories'))
      end
    end
  end

  def create
    authorize! :manage, PlatformCategory

    @platform_category = PlatformCategory.new(params[:platform_category])
    @platform_category.owner_id = current_user.id

    if @platform_category.save
      flash[:notice] = I18n.t (:notice_platform_category_successful_created)
      redirect_to redirect_apply(nil, new_organization_platform_categories_path(@organization), edit_organization_path(:anchor => 'tabs-platform-categories'))
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage, PlatformCategory

    @platform_category = nil
    current_platform_category = PlatformCategory.find(params[:id])
    if current_platform_category.is_defined?
      @platform_category = current_platform_category.amoeba_dup
      @platform_category.owner_id = current_user.id
    else
      @platform_category = current_platform_category
    end

    if @platform_category.update_attributes(params[:platform_category])
      flash[:notice] = I18n.t (:notice_platform_category_successful_updated)
      redirect_to redirect_apply(nil, new_organization_platform_categories_path(@organization), edit_organization_path(:anchor => 'tabs-platform-categories'))
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, PlatformCategory

    @platform_category = PlatformCategory.find(params[:id])
    if @platform_category.is_defined? || @platform_category.is_custom?
      #logical deletion: delete don't have to suppress records anymore
      @platform_category.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
    else
      @platform_category.destroy
    end

    flash[:notice] = I18n.t (:notice_platform_category_successful_deleted)
    redirect_to edit_organization_path(:anchor => 'tabs-platform-categories')
  end
end
