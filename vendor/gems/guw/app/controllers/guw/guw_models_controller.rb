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


class Guw::GuwModelsController < ApplicationController

  def show
    @guw_model = Guw::GuwModel.find(params[:id])
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.edit_organization_path(@guw_model.organization), @guw_model.organization => ""
  end

  def new
    @guw_model = Guw::GuwModel.new
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.edit_organization_path(@guw_model.organization), @guw_model.organization => ""
  end

  def edit
    @guw_model = Guw::GuwModel.find(params[:id])
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.edit_organization_path(@guw_model.organization), @guw_model.organization => ""
  end

  def create
    @guw_model = Guw::GuwModel.new(params[:guw_model])
    @guw_model.organization_id = params[:guw_model][:organization_id].to_i
    @guw_model.save
    redirect_to main_app.edit_organization_path(@guw_model.organization_id)
  end

  def update
    @guw_model = Guw::GuwModel.find(params[:id])
    @guw_model.update_attributes(params[:guw_model])
    redirect_to main_app.edit_organization_path(@guw_model.organization_id)
  end

  def destroy
    @guw_model = Guw::GuwModel.find(params[:id])
    organization_id = @guw_model.organization_id
    @guw_model.delete
    redirect_to main_app.edit_organization_path(organization_id)
  end
end