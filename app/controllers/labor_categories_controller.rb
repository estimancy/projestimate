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

class LaborCategoriesController < ApplicationController
  load_resource
  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  def index
    authorize! :create_and_edit_labor_categories, LaborCategory

    set_page_title 'Labors Categories'
    @labor_categories = LaborCategory.all
  end

  def new
    authorize! :create_and_edit_labor_categories, LaborCategory

    set_page_title 'Labors Categories'
    @labor_category = LaborCategory.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    authorize! :create_and_edit_labor_categories, LaborCategory

    set_page_title 'Labors Categories'
    @labor_category = LaborCategory.find(params[:id])

    unless @labor_category.child_reference.nil?
      if @labor_category.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_labor_category_cant_be_edit)
        redirect_to redirect(labor_categories_path)
      end
    end
  end

  def create
    authorize! :create_and_edit_labor_categories, LaborCategory

    @labor_category = LaborCategory.new(params[:labor_category])
    if @labor_category.save
      flash[:notice] = I18n.t (:notice_labor_category_successful_created)
      redirect_to redirect_apply(nil, new_labor_category_path(), labor_categories_path)
    else
      render action: 'new'
    end
  end

  def update
    authorize! :create_and_edit_labor_categories, LaborCategory

    @labor_category = nil
    current_labor_category = LaborCategory.find(params[:id])
    if current_labor_category.is_defined?
      @labor_category = current_labor_category.amoeba_dup
      @labor_category.owner_id = current_user.id
    else
      @labor_category = current_labor_category
    end

    if @labor_category.update_attributes(params[:labor_category])
      flash[:notice] = I18n.t (:notice_labor_category_successful_updated)
      redirect_to redirect_apply(edit_labor_category_path(@labor_category), nil, labor_categories_path)
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, LaborCategory

    @labor_category = LaborCategory.find(params[:id])
    if @labor_category.is_defined? || @labor_category.is_custom?
      #logical deletion: delete don't have to suppress records anymore
      @labor_category.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
    else
      @labor_category.destroy
    end

    flash[:notice] = I18n.t (:notice_labor_category_successful_deleted)
    redirect_to labor_categories_path
  end

end
