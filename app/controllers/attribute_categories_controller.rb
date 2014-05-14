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
#    ===================================================================
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
########################################################################
#
class AttributeCategoriesController < ApplicationController
  load_resource
  include DataValidationHelper #Module for master data changes validation
  before_filter :get_record_statuses
                               # GET /attribute_categories
                               # GET /attribute_categories.json
  def index
    authorize! :create_and_edit_attributes, PeAttribute

    set_page_title 'Attributes Categories'
    @attribute_categories = AttributeCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @attribute_categories }
    end
  end

  # GET /attribute_categories/new
  # GET /attribute_categories/new.json
  def new
    authorize! :manage, PeAttribute

    set_page_title 'Attributes Categories'
    @attribute_category = AttributeCategory.new
  end

  # GET /attribute_categories/1/edit
  def edit
    authorize! :create_and_edit_attributes, PeAttribute

    set_page_title 'Attributes Categories'
    @attribute_category = AttributeCategory.find(params[:id])
  end

  # POST /attribute_categories
  # POST /attribute_categories.json
  def create
    authorize! :manage, PeAttribute

    set_page_title 'Attributes Categories'
    @attribute_category = AttributeCategory.new(params[:attribute_category])

    if @attribute_category.save
      flash[:notice] = I18n.t (:notice_attribute_category_successful_created)
      redirect_to redirect_apply(nil, new_attribute_category_path(),attribute_categories_path)
    else
      render action: 'edit'
    end
  end

  # PUT /attribute_categories/1
  # PUT /attribute_categories/1.json
  def update
    authorize! :manage, PeAttribute

    @attribute_category = AttributeCategory.find(params[:id])

    if @attribute_category.update_attributes(params[:attribute_category])
      flash[:notice] = I18n.t (:notice_attribute_category_successful_updated)
      redirect_to redirect_apply(edit_attribute_category_path(@attribute_category), nil,attribute_categories_path)
    else
      flash[:error] = I18n.t (:error_attribute_category_failed_update)
      render action: 'edit'
    end
  end

  # DELETE /attribute_categories/1
  # DELETE /attribute_categories/1.json
  def destroy
    authorize! :manage, PeAttribute

    @attribute_category = AttributeCategory.find(params[:id])
    @attribute_category.destroy

    respond_to do |format|
      format.html { redirect_to attribute_categories_url }
      format.json { head :no_content }
    end
  end
end
