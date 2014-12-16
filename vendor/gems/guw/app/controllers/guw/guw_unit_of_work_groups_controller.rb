# encoding: UTF-8
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


class Guw::GuwUnitOfWorkGroupsController < ApplicationController

  def new
    @guw_unit_of_work_group = Guw::GuwUnitOfWorkGroup.new
  end

  def edit
    @guw_unit_of_work_group = Guw::GuwUnitOfWorkGroup.find(params[:id])
  end

  def create
    @guw_unit_of_work_group = Guw::GuwUnitOfWorkGroup.new(params[:guw_unit_of_work_group])
    @guw_unit_of_work_group.module_project_id = current_module_project.id
    @guw_unit_of_work_group.pbs_project_element_id = current_component.id
    @guw_unit_of_work_group.save
    redirect_to main_app.dashboard_path(@project)
  end

  def update
    @guw_unit_of_work_group = Guw::GuwUnitOfWorkGroup.find(params[:id])
    @guw_unit_of_work_group.update_attributes(params[:guw_unit_of_work_group])
    redirect_to main_app.dashboard_path(@project)
  end

  def destroy
    @guw_unit_of_work_group = Guw::GuwUnitOfWorkGroup.find(params[:id])
    @guw_unit_of_work_group.destroy
    redirect_to main_app.dashboard_path(@project)
  end

end
