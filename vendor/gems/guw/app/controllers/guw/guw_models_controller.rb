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


class Guw::GuwModelsController < ApplicationController

  require 'rubyXL'

  def exportxl
    workbook = RubyXL::Workbook.new
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_organisation = @guw_model.organization
    @guw_types = @guw_model.guw_types
    my_flag = false
    my_flag2 = true
    ind2 = 3
    ind3 = 0
    ind = 0
    @guw_types.each do |guw_type|
      if my_flag == true
        worksheet = workbook.add_worksheet(guw_type.name)
      else
        worksheet = workbook[0]
        worksheet.sheet_name = guw_type.name
        my_flag = true
      end
      worksheet.change_column_width(0, 65)
      @guw_complexities = guw_type.guw_complexities
      @guw_complexities.each do |guw_complexity|
        worksheet.merge_cells(0, ind + 1, 0, ind + 4)
        worksheet.change_row_horizontal_alignment(0, 'center')
        worksheet.add_cell(0, ind + 1, guw_complexity.name)
        worksheet.change_row_horizontal_alignment(1, 'center')
        worksheet.merge_cells(1, ind + 2, 1, ind + 4)
        worksheet.add_cell(1, ind + 2, "[ ; [ / Poids ")
        worksheet.add_cell(2, ind + 2, guw_complexity.bottom_range)
        worksheet.add_cell(2, ind + 3, guw_complexity.top_range)
        worksheet.add_cell(2, ind + 4, guw_complexity.weight)
      #  worksheet.change_column_width(ind + 2, 15)
        worksheet.add_cell(1, ind + 1, "Prod")
        worksheet.add_cell(2, ind + 1, guw_complexity.enable_value ? 1 : 0)
        if my_flag2 == 1
          worksheet.merge_cells(ind2, ind, ind2, ind + 1)
        else
          worksheet.merge_cells(ind2, ind - 4, ind2, ind + 4)
        end
        worksheet.change_row_bold(ind2,true)
        worksheet.add_cell(ind2 , 0,  "Coefficient d'acquisiton")
        guw_complexity.guw_complexity_work_units.each do |guw_complexity_work_unit|
          if my_flag2 == true
            worksheet.add_cell(ind2 - 1, 0, "seuil")
            worksheet.sheet_data[ind2 - 1][0].change_font_bold(true)
            my_flag2 = false
          end
          @guw_work_unit = guw_complexity_work_unit.guw_work_unit
          cu = Guw::GuwComplexityWorkUnit.where(guw_complexity_id: guw_complexity.id, guw_work_unit_id: @guw_work_unit.id).first
          worksheet.add_cell(ind2 + 1, 0, @guw_work_unit.name)
          worksheet.merge_cells(ind2 + 1, ind + 1, ind2 + 1, ind + 4)
          worksheet.merge_cells(ind2 + 1, ind + 1, ind2 + 1, ind + 4)
          worksheet.add_cell(ind2 + 1, ind + 1, cu.value)
          ind2 += 1
        end
        worksheet.merge_cells(ind2 + 1, ind, ind2 + 1,ind + 1)
        worksheet.change_row_bold(ind2 + 1,true)
        worksheet.add_cell(ind2 + 1, 0, 'Technologie')
        guw_complexity.guw_complexity_technologies.each do |complexity_technology|
          @guw_organisation_technology = complexity_technology.organization_technology
          ct = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_complexity.id, organization_technology_id: @guw_organisation_technology.id).first
          worksheet.add_cell(ind2 + 2, 0, @guw_organisation_technology.name)
          worksheet.merge_cells(ind2 + 1, ind + 1, ind2 + 1, ind + 4)
          worksheet.merge_cells(ind2 + 2, ind + 1, ind2 + 2, ind + 4)
          worksheet.add_cell(ind2 + 2, ind + 1, ct.coefficient)
          ind2 += 1
          ind3 += 1
        end
        ind2 = 3
        ind += 4
      end
      ind = 0
      worksheet.add_cell(ind3 - 1, ind, "Seuils de complexité")
      worksheet.sheet_data[ind3 - 1][ind].change_font_bold(true)
      worksheet.add_cell(ind3, ind, "Attributs")
      worksheet.sheet_data[ind3][ind].change_font_bold(true)
      guw_type.guw_type_complexities.each  do |type_attribute_complexity|
        worksheet.merge_cells(ind3 - 1, ind + 1, ind3 - 1, ind + 4)
        worksheet.add_cell(ind3 - 1, ind + 1, type_attribute_complexity.name)
        worksheet.sheet_data[ind3 - 1][ind + 1].change_horizontal_alignment('center')
        worksheet.add_cell(ind3 , ind + 1, "Prod")
        worksheet.sheet_data[ind3][ind + 1].change_horizontal_alignment('center')
        worksheet.merge_cells(ind3, ind + 2, ind3, ind + 4)
        worksheet.add_cell(ind3 , ind + 2, "[ ; [ / Poids ")
        worksheet.sheet_data[ind3][ind + 2].change_horizontal_alignment('center')
        ind4 = ind3 + 1
        @guw_model.guw_attributes.order("name ASC").each do |attribute|
          if ind == 0
            worksheet.add_cell(ind4, ind, attribute.name)
          end
          att_val = Guw::GuwAttributeComplexity.where(guw_type_complexity_id: type_attribute_complexity.id, guw_attribute_id: attribute.id).first
          unless att_val.nil?
            worksheet.add_cell(ind4, ind + 1, att_val.enable_value ? 1 : 0)
            worksheet.add_cell(ind4, ind + 2, att_val.bottom_range)
            worksheet.add_cell(ind4, ind + 3, att_val.top_range)
            worksheet.add_cell(ind4, ind + 4, att_val.value)
            ind4 += 1
          end
        end
        ind += 4
      end
      my_flag2 = true
      ind = 0
      ind3 = 0
    end
    workbook.write("#{Rails.root}/public/export.xlsx")
    redirect_to "#{SETTINGS['HOST_URL']}/export.xlsx"
  end

  def show

    authorize! :show_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])
    set_page_title @guw_model.name
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.organization_module_estimation_path(@guw_model.organization), @guw_model.organization => ""
  end

  def new
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])
    @guw_model = Guw::GuwModel.new
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.organization_module_estimation_path(params['organization_id']), @guw_model.organization => ""
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])
    @organization = @guw_model.organization
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.organization_module_estimation_path(@guw_model.organization), @guw_model.organization => ""
  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:guw_model][:organization_id])
    @guw_model = Guw::GuwModel.new(params[:guw_model])
    @guw_model.organization_id = params[:guw_model][:organization_id].to_i

    if @guw_model.save
      redirect_to main_app.organization_module_estimation_path(@guw_model.organization_id)
    else
      render action: :new
    end
  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])
    @organization = @guw_model.organization

    if @guw_model.update_attributes(params[:guw_model])
      redirect_to main_app.organization_module_estimation_path(@guw_model.organization_id)
    else
      render action: :edit
    end
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

    new_copy_number = @guw_model.copy_number.to_i+1
    new_guw_model.name = "#{@guw_model.name}(#{new_copy_number})"
    new_guw_model.copy_number = 0
    @guw_model.copy_number = new_copy_number

    #Terminate the model duplication
    new_guw_model.transaction do
      if new_guw_model.save
        @guw_model.save
        new_guw_model.terminate_guw_model_duplication
      end
    end

    redirect_to main_app.organization_module_estimation_path(@guw_model.organization_id, anchor: "taille")
  end

  def export
    @guw_model = current_module_project.guw_model
    @component = current_component
    @guw_unit_of_works = Guw::GuwUnitOfWork.where(module_project_id: current_module_project.id,
                                                  pbs_project_element_id: @component.id,
                                                  guw_model_id: @guw_model.id)
    workbook = RubyXL::Workbook.new
    worksheet = workbook.worksheets[0]

    tmp = Array.new

    tmp << [
          "Estimation",
          "Version",
          "Groupe",
          "Sélectionné",
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

      @guw_unit_of_works.each do |uow|

        array_uo = Array.new
        array_value = Array.new

        if uow.off_line == true
          cplx = "HSAT"
        elsif uow.off_line_uo
          cplx = "HSUO"
        elsif uow.guw_complexity.nil?
          cplx = "-"
        else
          cplx = uow.guw_complexity.name
        end

        array_uo << [
            current_module_project.project.title,
            current_module_project.project.version,
            uow.guw_unit_of_work_group.name,
            uow.selected == true ? 'Oui' : 'Non',
            uow.name,
            uow.comments,
            uow.guw_type,
            uow.guw_work_unit,
            uow.organization_technology,
            uow.tracking,
            cplx,
            uow.effort,
            uow.ajusted_effort
        ]

        @guw_model.guw_attributes.each do |guw_attribute|
          uowa = Guw::GuwUnitOfWorkAttribute.where(guw_unit_of_work_id: uow.id, guw_attribute_id: guw_attribute.id).first
          if uowa.blank?
            array_value << '-'
          else
            array_value << uowa.most_likely
          end
        end

        tmp << (array_uo + array_value).flatten
      end

      tmp.each_with_index do |r, i|
        tmp[i].each_with_index do |r, j|
          worksheet.add_cell(i, j, tmp[i][j])
        end
      end

    tmp_filename = "export-uo-#{Time.now.strftime('%d-%m-%Y')}"
    filename = tmp_filename.gsub(" ", '-')
    workbook.write("#{Rails.root}/public/#{filename}.xlsx")
    redirect_to "#{SETTINGS['HOST_URL']}/#{filename}.xlsx"
  end

end
