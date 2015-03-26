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


class Guw::GuwAttributesController < ApplicationController
  def index
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_attributes = @guw_model.guw_attributes.order("name ASC")
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.edit_organization_path(@guw_model.organization), @guw_model.organization => ""
  end

  def new
    @guw_attribute = Guw::GuwAttribute.new
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.edit_organization_path(@guw_model.organization), @guw_model.organization => ""
  end

  def edit
    @guw_attribute = Guw::GuwAttribute.find(params[:id])
    @guw_model = @guw_attribute.guw_model
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.edit_organization_path(@guw_model.organization), @guw_model.organization => ""
  end

  def create
    @guw_attribute = Guw::GuwAttribute.new(params[:guw_attribute])
    @guw_attribute.save
    redirect_to guw.guw_model_guw_attributes_path(@guw_attribute.guw_model)
  end

  def update
    @guw_attribute = Guw::GuwAttribute.find(params[:id])
    @guw_attribute.update_attributes(params[:guw_attribute])
    redirect_to guw.guw_model_guw_attributes_path(@guw_attribute.guw_model)
  end

  def destroy
    @guw_attribute = Guw::GuwAttribute.find(params[:id])
    model_id = @guw_attribute.guw_model
    @guw_attribute.delete
    redirect_to guw.guw_model_guw_attributes_path(model_id)
  end
end
