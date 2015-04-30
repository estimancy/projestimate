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

  def export
    @guw_model = current_module_project.guw_model
    @component = current_component
    @guw_unit_of_works = Guw::GuwUnitOfWork.where(module_project_id: current_module_project.id,
                                                  pbs_project_element_id: @component.id,
                                                  guw_model_id: @guw_model.id)

    csv_string = CSV.generate(:col_sep => I18n.t(:general_csv_separator)) do |csv|

      csv << [
          "Nom",
          "Description",
          "Type d'UO",
          "Opération",
          "Technologie",
          "Tracabilité",
          "Cotation",
          "Résultat",
          "Retenu"
      ] + @guw_model.guw_attributes.map(&:name)

      tmp = Array.new
      @guw_unit_of_works.each do |uow|
        tmp = [
            uow.name,
            uow.comments,
            uow.guw_type,
            uow.guw_work_unit,
            uow.organization_technology,
            uow.tracking,
            uow.guw_complexity.name,
            uow.effort,
            uow.ajusted_effort
        ]

        @guw_model.guw_attributes.each do |guw_attribute|
          uowa = Guw::GuwUnitOfWorkAttribute.where(guw_unit_of_work_id: uow.id, guw_attribute_id: guw_attribute.id).first
          tmp = tmp + [ uowa.blank? ? '-' : uowa.most_likely ]
        end

        csv << tmp
      end
    end
    send_data(csv_string.encode("ISO-8859-1"), :type => 'text/csv; header=present', :disposition => "attachment; filename=Export-UOs-#{Time.now}.csv")
  end

end
