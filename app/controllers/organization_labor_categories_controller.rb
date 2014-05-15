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
#############################################################################

class OrganizationLaborCategoriesController < ApplicationController

  def index
    @organization_labor_categories = OrganizationLaborCategory.all
  end

  def new
    @organization_labor_category = OrganizationLaborCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @organization_labor_category }
    end
  end

  def edit
    @organization_labor_category = OrganizationLaborCategory.find(params[:id])
  end

  def create
    @organization_labor_category = OrganizationLaborCategory.new(params[:organization_labor_category])


    if @organization_labor_category.save
      flash[:notice] = I18n.t (:notice_organization_labor_successful_created)
      redirect_to redirect_apply(nil, new_organization_labor_category_path(), '/organizationals_params#tabs-3')
    else
       render action: 'new'
    end

  end

  def update
    @organization_labor_category = OrganizationLaborCategory.find(params[:id])


    if @organization_labor_category.update_attributes(params[:organization_labor_category])
      flash[:notice] = I18n.t (:notice_organization_labor_successful_updated)
      redirect_to redirect_apply(edit_organization_labor_category_path(@organization_labor_category),nil,'/organizationals_params#tabs-3')
    else
      render action: 'edit'
    end

  end

  def destroy
    @organization_labor_category = OrganizationLaborCategory.find(params[:id])
    @organization_labor_category.destroy

    respond_to do |format|
      format.html { redirect_to redirect('/organizationals_params#tabs-3'), notice: "#{I18n.t (:notice_organization_labor_successful_deleted)}"}
    end
  end
end
