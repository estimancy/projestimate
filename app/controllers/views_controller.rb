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
#############################################################################

class ViewsController < ApplicationController
  # GET /views
  # GET /views.json
  def index
    @views = View.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @views }
    end
  end

  # GET /views/1
  # GET /views/1.json
  def show
    @view = View.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @view }
    end
  end

  # GET /views/new
  # GET /views/new.json
  def new
    @view = View.new
    @organization = Organization.find_by_id(params[:organization_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @view }
    end
  end

  # GET /views/1/edit
  def edit
    @view = View.find(params[:id])
    @organization = @view.organization
  end

  # POST /views
  # POST /views.json
  def create
    @view = View.new(params[:view])
    @organization = Organization.find_by_id(params['view']['organization_id'])

    respond_to do |format|
      if @view.save
        flash[:notice] = I18n.t(:view_successfully_created)
        format.html { redirect_to redirect_apply(nil, new_view_path(params[:view]), edit_organization_path(@organization, :anchor => 'tabs-views-widgets'))}
        format.json { render json: @view, status: :created, location: @view }
      else
        format.html { render action: "new", :organization_id => @organization.id }
        format.json { render json: @view.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /views/1
  # PUT /views/1.json
  def update
    @view = View.find(params[:id])
    @organization = @view.organization

    respond_to do |format|
      if @view.update_attributes(params[:view])
        flash[:notice] = I18n.t(:view_successfully_updated)
        format.html { redirect_to redirect_apply(edit_view_path(params[:view]), nil, edit_organization_path(@organization, :anchor => 'tabs-view-widgets')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit", :organization_id => @organization.id }
        format.json { render json: @view.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /views/1
  # DELETE /views/1.json
  def destroy
    @view = View.find(params[:id])
    organization_id = @view.organization_id
    @view.destroy
    redirect_to edit_module_project_path(params['module_project_id'], :anchor => 'tabs-view-widgets-parameters')
  end
end
