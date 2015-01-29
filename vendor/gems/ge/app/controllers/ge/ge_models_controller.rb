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


class Ge::GeModelsController < ApplicationController

  def show
    @ge_model = Ge::GeModel.find(params[:id])
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.edit_organization_path(@ge_model.organization), @ge_model.organization => ""
  end

  def new
    @ge_model = Ge::GeModel.new
  end

  def edit
    @ge_model = Ge::GeModel.find(params[:id])
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.edit_organization_path(@ge_model.organization), @ge_model.organization => ""
  end

  def create
    @ge_model = Ge::GeModel.new(params[:ge_model])
    @ge_model.organization_id = params[:ge_model][:organization_id].to_i
    @ge_model.save
    redirect_to main_app.edit_organization_path(@ge_model.organization_id)
  end

  def update
    @ge_model = Ge::GeModel.find(params[:id])
    @ge_model.update_attributes(params[:ge_model])
    redirect_to main_app.edit_organization_path(@ge_model.organization_id)
  end

  def destroy
    @ge_model = Ge::GeModel.find(params[:id])
    organization_id = @ge_model.organization_id
    @ge_model.delete
    redirect_to main_app.edit_organization_path(organization_id)
  end

  def save_efforts
    @ge_model = Ge::GeModel.find(params[:ge_model_id])
    current_module_project.pemodule.attribute_modules.each do |am|
      tmp_prbl = Array.new

      ev = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => am.pe_attribute.id).first

      ["low", "most_likely", "high"].each do |level|
        if am.pe_attribute.alias == "effort"
          effort = (@ge_model.coeff_a * params[:"retained_size_#{level}"].to_f ** @ge_model.coeff_b) * @ge_model.standard_unit_coefficient
          ev.send("string_data_#{level}")[current_component.id] = effort
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
        elsif am.pe_attribute.alias == "retained_size"
          ev = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => am.pe_attribute.id).first
          ev.send("string_data_#{level}")[current_component.id] = params[:"retained_size_#{level}"]
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
        end
      end

      ev.update_attribute(:"string_data_probable", { current_component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) } )

    end
    redirect_to main_app.dashboard_path(@project)
  end

end
