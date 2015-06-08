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
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################


class Guw::GuwWorkUnitsController < ApplicationController

  def index
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_work_units = @guw_model.guw_work_units
  end

  def new
    @guw_work_unit = Guw::GuwWorkUnit.new
  end

  def edit
    @guw_work_unit = Guw::GuwWorkUnit.find(params[:id])
  end

  def create
    @guw_work_unit = Guw::GuwWorkUnit.new(params[:guw_work_unit])
    @guw_work_unit.save
    redirect_to guw.guw_model_guw_work_units_path(@guw_work_unit.guw_model)
  end

  def update
    @guw_work_unit = Guw::GuwWorkUnit.find(params[:id])
    @guw_work_unit.update_attributes(params[:guw_work_unit])
    redirect_to guw.guw_model_guw_work_units_path(@guw_work_unit.guw_model)
  end

  def destroy
    @guw_work_unit = Guw::GuwWorkUnit.find(params[:id])
    guw_model_id = @guw_work_unit.guw_model.id
    @guw_work_unit.delete
    redirect_to guw.guw_model_path(guw_model_id)
  end
end
