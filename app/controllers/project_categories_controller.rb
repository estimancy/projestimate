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

class ProjectCategoriesController < ApplicationController
  #include DataValidationHelper #Module for master data changes validation

  load_resource

  #before_filter :get_record_statuses

  def new
    authorize! :manage, ProjectCategory

    set_page_title 'Project Category'
    @project_category = ProjectCategory.new
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    authorize! :show_project_categories, ProjectCategory

    set_page_title 'Project Category'
    @project_category = ProjectCategory.find(params[:id])
    @organization = Organization.find(params[:organization_id])
  end

  def create
    authorize! :manage, ProjectCategory

    @project_category = ProjectCategory.new(params[:project_category])
    @organization = Organization.find(params[:organization_id])

    if @project_category.save
      flash[:notice] = I18n.t (:notice_project_categories_successful_created)
      redirect_to redirect_apply(nil, new_organization_project_category_path(@organization), organization_setting_path(@organization, :anchor => 'tabs-project-categories'))
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage, ProjectCategory

    @organization = Organization.find(params[:organization_id])
    @project_category = ProjectCategory.find(params[:id])

    if @project_category.update_attributes(params[:project_category])
      flash[:notice] = I18n.t (:notice_project_categories_successful_updated)
      redirect_to redirect_apply(edit_organization_project_category_path(@organization, @project_category), nil, organization_setting_path(@organization, :anchor => 'tabs-project-categories'))
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, ProjectCategory

    @project_category = ProjectCategory.find(params[:id])
    organization_id = @project_category.organization_id
    @project_category.destroy

    flash[:notice] = I18n.t (:notice_project_categories_successful_deleted)
    redirect_to organization_setting_path(organization_id, :anchor => 'tabs-project-categories')
  end
end
