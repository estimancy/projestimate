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

    if @view.save
      flash[:notice] = I18n.t(:view_successfully_created)
      redirect_to redirect_apply(nil, new_view_path(params[:view]), organization_setting_path(@organization, :anchor => 'tabs-views'))
    else
      render action: "new", :organization_id => @organization.id
    end
  end

  # PUT /views/1
  # PUT /views/1.json
  def update
    @view = View.find(params[:id])
    @organization = @view.organization

    if @view.update_attributes(params[:view])
      flash[:notice] = I18n.t(:view_successfully_updated)
      redirect_to redirect_apply(edit_organization_view_path(params[:view]), nil, organization_setting_path(@organization, :anchor => 'tabs-views'))
    else
      render action: "edit", :organization_id => @organization.id
    end

  end

  # DELETE /views/1
  # DELETE /views/1.json
  def destroy
    @view = View.find(params[:id])
    @organization = @view.organization
    organization_id = @view.organization_id
    view_pemodule = @view.pemodule
    #Get the view module_projects
    view_module_projects = @view.module_projects

    @view.destroy

    # the organization default view
    @organization_default_view = View.where("organization_id = ? AND pemodule_id = ? AND is_default_view = ?",  organization_id, view_pemodule.id, true).first_or_create(organization_id: organization_id, pemodule_id: view_pemodule.id, is_default_view: true, :description => "Default view for the #{view_pemodule}. If no view is selected for module project, this view will be automatically selected.")

    #After destroy, we need to assigned all this view module_project to the organization default view
    view_module_projects.update_all(view_id: @organization_default_view)

    redirect_to organization_setting_path(@organization, :anchor => 'tabs-views')
  end
end
