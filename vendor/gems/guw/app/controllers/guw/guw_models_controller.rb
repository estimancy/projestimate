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
    authorize! :show_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.organization_module_estimation_path(@guw_model.organization), @guw_model.organization => ""
  end

  def new
    authorize! :manage_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.new
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.organization_module_estimation_path(params['organization_id']), @guw_model.organization => ""
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.organization_module_estimation_path(@guw_model.organization), @guw_model.organization => ""
  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.new(params[:guw_model])
    @guw_model.organization_id = params[:guw_model][:organization_id].to_i
    @guw_model.save
    redirect_to main_app.organization_module_estimation_path(@guw_model.organization_id)
  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])
    @guw_model.update_attributes(params[:guw_model])
    redirect_to main_app.organization_module_estimation_path(@guw_model.organization_id)
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])
    organization_id = @guw_model.organization_id
    @guw_model.module_projects.each do |mp|
      mp.destroy
    end
    @guw_model.delete
    redirect_to main_app.organization_module_estimation_path(@guw_model.organization_id)
  end

  def duplicate
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    new_guw_model = @guw_model.amoeba_dup

    #Terminate the model duplication
    new_guw_model.transaction do
      if new_guw_model.save
        new_guw_model.terminate_guw_model_duplication
      end
    end

    redirect_to main_app.organization_module_estimation_path(@guw_model.organization_id)
  end


  def duplicate_save
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @organization = @guw_model.organization
    guw_model = @guw_model.amoeba_dup

    if guw_model.save

      guw_model.guw_types.each do |guw_type|

        # Copy the complexities technologies
        guw_type.guw_complexities.each do |guw_complexity|
          # Copy the complexities technologie
          guw_complexity.guw_complexity_technologies.each do |guw_complexity_technology|
            new_organization_technology = @organization.organization_technologies.where(copy_id: guw_complexity_technology.organization_technology_id).first
            unless new_organization_technology.nil?
              guw_complexity_technology.update_attribute(:organization_technology_id, new_organization_technology.id)
            end
          end

          # Copy the complexities units of works
          guw_complexity.guw_complexity_work_units.each do |guw_complexity_work_unit|
            new_guw_work_unit = guw_model.guw_work_units.where(copy_id: guw_complexity_work_unit.guw_work_unit_id).first
            unless new_guw_work_unit.nil?
              guw_complexity_work_unit.update_attribute(:guw_work_unit_id, new_guw_work_unit.id)
            end
          end
        end

        # Copy the GUW-attribute-complexity
        guw_type.guw_type_complexities.each do |guw_type_complexity|
          guw_type_complexity.guw_attribute_complexities.each do |guw_attr_complexity|
            new_guw_attribute = guw_model.guw_attributes.where(copy_id: guw_attr_complexity.guw_attribute_id).first
            unless new_guw_attribute.nil?
              guw_attr_complexity.update_attributes(guw_type_id: guw_type_complexity.guw_type_id, guw_attribute_id: new_guw_attribute.id)
            end
          end
        end
      end
    end

    redirect_to main_app.organization_module_estimation_path(@guw_model.organization_id)
  end

end
