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

  def redirect_to_good_path(route_flag)
    if route_flag == 1
      redirect_to :back
      flash[:error] = "imposible de cree se model, model deja existant"
    elsif route_flag == 2
      redirect_to :back
      flash[:error] = "nom du model invalide merci de verifier le classeur importer"
    else
      redirect_to "/organizations/#{@current_organization.id}/module_estimation"
      flash[:notice] = "model importer avec suces"
    end
  end

  def importxl
    @workbook = RubyXL::Parser.parse(params[:file].path)
    #@guw_model = Guw::GuwModel.find(params[:guw_model_id])
    #@guw_organisation = @guw_model.organization
    #@guw_types = @guw_model.guw_types
    element_found_flag = false
    route_flag = 0
    flag = false
    ind = 8
    ind2 = 1
    ind3 = 0
    save_position = 0
    @workbook.each_with_index do |worksheet, index|
      tab = worksheet.extract_data
      if index < 3
        #ici on recupere les information sur le model
        if index == 0
          if tab[0][1].nil? || tab[0][1].empty?
            route_flag = 2
            break
          end
          @guw_model = Guw::GuwModel.find_by_name(tab[0][1])
          if @guw_model.nil?
            @guw_model = Guw::GuwModel.new(name: tab[0][1],
                                           description: tab[1][1],
                                           three_points_estimation: tab[2][1] == 1 ? true : false,
                                           retained_size_unit: tab[3][1],
                                           organization_id: @current_organization.id)
            @guw_model.save
          else
            route_flag = 1
            break
          end
        elsif index == 1
          tab.each_with_index do |row, index|
            if index != 0
              Guw::GuwAttribute.where(name: row[0], guw_model_id: @guw_model.id).first_or_create(name: row[0],
                                                                                                 description: row[1],
                                                                                                 guw_model_id: @guw_model.id)
            end
          end
        elsif index == 2
          tab.each_with_index do |row, index|
            if index != 0
              Guw::GuwWorkUnit.where(name:row[0], guw_model_id: @guw_model.id).first_or_create(name:row[0],
                                                                                               value: row[1],
                                                                                               display_order: row[2],
                                                                                               guw_model_id: @guw_model.id)
            end
          end
        end
      else
        tab.each_with_index do |row, index|
          if guw_type
            guw_type = Guw::GuwType.create(name: worksheet.sheet_name)
          end
        end
=begin
        @guw_types.each do |guw_type|
          if guw_type.name == worksheet.sheet_name
            if tab[ind][0]== "Seuil"
              guw_type.guw_complexities.each do |guw_complexity|
                if guw_complexity.name == tab[ind - 2][ind2]
                  guw_complexity.enable_value = tab[ind][ind2] == 0 ? false : true
                  guw_complexity.bottom_range = tab[ind][ind2 + 1]
                  guw_complexity.top_range = tab[ind][ind2 + 2]
                  guw_complexity.weight = tab[ind][ind2 + 3]
                  ind += 1
                  if tab[ind][0] == "Coefficient d'acquisiton"
                    ind += 1
                    while !tab[ind].nil? && tab[ind][0] != "Technologie"
                      guw_complexity.guw_complexity_work_units.each do |guw_complexity_work_unit|
                        @guw_work_unit = guw_complexity_work_unit.guw_work_unit
                        if @guw_work_unit.name == tab[ind][0]
                          cu = Guw::GuwComplexityWorkUnit.where(guw_complexity_id: guw_complexity.id, guw_work_unit_id: @guw_work_unit.id).first
                          cu.value = tab[ind][ind2]
                          cu.save
                          break
                        end
                      end
                      ind += 1
                    end
                    if tab[ind][0] == "Technologie"
                      while !tab[ind].nil? && !tab[ind].empty?
                        guw_complexity.guw_complexity_technologies.each do |complexity_technology|
                          @guw_organisation_technology = complexity_technology.organization_technology
                          if @guw_organisation_technology.name ==  tab[ind][0]
                            ct = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_complexity.id, organization_technology_id: @guw_organisation_technology.id).first
                            if ct
                              ct.coefficient = tab[ind][ind2]
                              ct.save
                              break
                            end
                          end
                        end
                        ind += 1
                      end
                    end
                  end
                  element_found_flag = true
                end
                guw_complexity.save
                ind2 += 4
                ind3 = ind + 1
                ind = 8
              end
              if element_found_flag == false
                # #ici on cree une nouvelle complexiter
                # ind2 = 0
                toto = 42
              else
                element_found_flag = false
              end
              ind = 8
            end #parti pour le seuil
            ind2 = 1
            if tab[ind3][0] == "Seuils de complexité"
               ind3 += 1
                if tab[ind3][0] == "Attributs"
                  save_position = ind3 - 1
                  ind3 += 1
                  while !tab[save_position][ind2].nil? && !tab[save_position][ind2].empty?
                    while tab[ind3]
                      @guw_model.guw_attributes.each do |attribute|
                        if attribute.name == tab[ind3][0]
                          guw_type.guw_type_complexities.each  do |type_attribute_complexity|
                            if type_attribute_complexity.name == tab[save_position][ind2]
                               att_val = Guw::GuwAttributeComplexity.where(guw_type_complexity_id: type_attribute_complexity.id, guw_attribute_id: attribute.id).first
                              if !att_val.nil?
                                att_val.enable_value = tab[ind3][ind2] == 0 ? false : true
                                att_val.bottom_range = tab[ind3][ind2 + 1]
                                att_val.top_range = tab[ind3][ind2 + 2]
                                att_val.value = tab[ind3][ind2 + 3]
                                att_val.save
                                break
                             end
                            end
                          end
                        end
                      end
                      ind3 += 1
                    end
                    ind3 = save_position
                    ind2 += 4
                  end
                end
            end
          end
        end
=end #boucle de remplissage des donner
      end
    end
    redirect_to_good_path(route_flag)
  end

  def deter_size(my_string)
    ind = 0
    len = 0
    while my_string[ind]
      if my_string[ind] == "\n"
        len += 1
      end
      ind += 1
    end
    return len
  end

  def the_most_largest(my_string)
    ind = 0
    len = 0
    len2 = 0
    while my_string[ind]
      if my_string[ind] == "\n" || my_string[ind + 1] == nil
        if len2 < len
          len2 = len
        end
        len = 0
      else
        len += 1
      end
      ind += 1
    end
    return len2
  end

  def exportxl
    workbook = RubyXL::Workbook.new
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_organisation = @guw_model.organization
    @guw_types = @guw_model.guw_types
    ind = 0
    ind2 = 1
    ind3 = 5

    worksheet = workbook[0]
    worksheet.sheet_name = "Model"
    workbook.add_worksheet("Atribut description")
    workbook.add_worksheet("Type d'acquisitions")
    worksheet.add_cell(0, 0, "Nom du model")
    worksheet.sheet_data[0][0].change_font_bold(true)
    worksheet.add_cell(0, 1, @guw_model.name)
    worksheet.sheet_data[0][1].change_horizontal_alignment('center')
    worksheet.add_cell(1, 0, "Description du model")
    worksheet.add_cell(1, 1, @guw_model.description)
    worksheet.add_cell(2, 0, "Estimation 3 points")
    worksheet.add_cell(2, 1, @guw_model.three_points_estimation ? 1 : 0)
    worksheet.sheet_data[2][1].change_horizontal_alignment('center')
    worksheet.add_cell(3, 0, "Libellé de l'unité de taille du modul")
    worksheet.add_cell(3, 1, @guw_model.retained_size_unit)
    worksheet.change_column_bold(0,true)
    worksheet.sheet_data[3][1].change_horizontal_alignment('center')
    worksheet.change_row_height(1,deter_size(@guw_model.description) * 13)
    worksheet.change_column_width(0, 38)
    worksheet.change_column_width(1, the_most_largest(@guw_model.description))

    worksheet = workbook[1]
    worksheet.add_cell(0, 0, "Nom de l'atrtibut")
    worksheet.add_cell(0, 1, "Description")
    worksheet.change_row_bold(0,true)
    worksheet.change_row_horizontal_alignment(0, 'center')
    @guw_model.guw_attributes.order("name ASC").each_with_index do |attribute, indx|
      worksheet.add_cell(indx + 1, 0, attribute.name)
      worksheet.add_cell(indx + 1, 1, attribute.description)
      if ind < attribute.name.size
        worksheet.change_column_width(0, attribute.name.size)
        ind = attribute.name.size
      end
      if ind2 < the_most_largest(attribute.description)
        worksheet.change_column_width(1, the_most_largest(attribute.description))
        ind2 = the_most_largest(attribute.description)
      end
    end
    ind = 0
    ind2 = 6

    worksheet = workbook[2]
    worksheet.change_row_bold(0,true)
    worksheet.add_cell(0, 0, "Nom")
    worksheet.add_cell(0, 1, "Valeur")
    worksheet.add_cell(0, 2, "Ordre d'affichage")
    worksheet.change_row_horizontal_alignment(0, 'center')
    worksheet.change_column_width(2, 18)
    @guw_model.guw_work_units.each_with_index do |aquisitions_type,indx|
      worksheet.add_cell(indx + 1, 0, aquisitions_type.name)
      worksheet.add_cell(indx + 1, 1, aquisitions_type.value)
      worksheet.add_cell(indx + 1, 2, aquisitions_type.display_order == 0 ? indx : aquisitions_type.display_order)
      if ind < aquisitions_type.name.size
        worksheet.change_column_width(0, aquisitions_type.name.size)
        ind = aquisitions_type.name.size
      end
    end
    ind = 0

    @guw_types.each do |guw_type|
      worksheet = workbook.add_worksheet(guw_type.name)
      #worksheet.change_row_bold(0,true)
      description = Nokogiri::HTML.parse(ActionView::Base.full_sanitizer.sanitize(guw_type.description)).text
      worksheet.add_cell(0, ind, description)
      worksheet.change_row_height(0, deter_size(description) * 15)
      worksheet.change_column_width(0, 65)


      worksheet.add_cell(1, 0,  "Activer le retenu")
      worksheet.sheet_data[1][0].change_font_bold(true)
      worksheet.add_cell(1, 1,  guw_type.allow_retained ? 1 : 0)

      worksheet.add_cell(2, 0,  "Activer la quantité")
      worksheet.sheet_data[2][0].change_font_bold(true)
      worksheet.add_cell(2, 1,  guw_type.allow_quantity ? 1 : 0)

      worksheet.add_cell(3, 0,  "Activer la complexité")
      worksheet.sheet_data[3][0].change_font_bold(true)
      worksheet.add_cell(3, 1,  guw_type.allow_complexity ? 1 : 0)

      worksheet.add_cell(4, 0, "Activer le dénombrement")
      worksheet.sheet_data[4][0].change_font_bold(true)
      worksheet.add_cell(4, 1,  guw_type.allow_criteria ? 1 : 0)

      @guw_complexities = guw_type.guw_complexities
      worksheet.change_row_horizontal_alignment(ind2, 'center')
      worksheet.change_row_horizontal_alignment( ind2 + 1, 'center')
      worksheet.change_row_bold(ind2,true)
      worksheet.change_row_bold(ind2 + 3,true)
      worksheet.add_cell(ind2 + 3, 0,  "Coefficient d'acquisiton")
      worksheet.add_cell(ind2 + 2, 0, "Seuil")
      worksheet.sheet_data[ind2 + 2][0].change_font_bold(true)
      @guw_complexities.each do |guw_complexity|
        worksheet.add_cell(ind2 + 1, ind + 2, "[    ;    [      /   Poids")
        worksheet.add_cell(ind2 + 1, ind + 1, "Prod")
        worksheet.merge_cells(0, 0, 0, ind + 4)
        worksheet.merge_cells(ind2, ind + 1, ind2, ind + 4)
        worksheet.merge_cells(ind2 + 3, 0, ind2 + 3, ind + 4)
        worksheet.merge_cells(ind2 + 1, ind + 2, ind2 + 1, ind + 4)
        worksheet.add_cell(ind2, ind + 1, guw_complexity.name)
        worksheet.add_cell(ind2 + 2, ind + 2, guw_complexity.bottom_range)
        worksheet.add_cell(ind2 + 2, ind + 3, guw_complexity.top_range)
        worksheet.add_cell(ind2 + 2, ind + 4, guw_complexity.weight)
        worksheet.add_cell(ind2 + 2, ind + 1, guw_complexity.enable_value ? 1 : 0)
        guw_complexity.guw_complexity_work_units.each do |guw_complexity_work_unit|
          @guw_work_unit = guw_complexity_work_unit.guw_work_unit
          cu = Guw::GuwComplexityWorkUnit.where(guw_complexity_id: guw_complexity.id, guw_work_unit_id: @guw_work_unit.id).first
          worksheet.add_cell(ind2 + 4, 0, @guw_work_unit.name)
          worksheet.merge_cells(ind2 + 4, ind + 1, ind2 + 4, ind + 4)
          worksheet.add_cell(ind2 + 4, ind + 1, cu.value)
          ind2 += 1
        end
        worksheet.merge_cells(ind2 + 4, 0, ind2 + 4, ind + 4)
        worksheet.change_row_bold(ind2 + 4,true)
        worksheet.add_cell(ind2 + 4, 0, "Technologie")
        guw_complexity.guw_complexity_technologies.each do |complexity_technology|
          @guw_organisation_technology = complexity_technology.organization_technology
          ct = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_complexity.id, organization_technology_id: @guw_organisation_technology.id).first
          worksheet.add_cell(ind2 + 5, 0, @guw_organisation_technology.name)
          worksheet.merge_cells(ind2 + 5, ind + 1, ind2 + 5, ind + 4)
          worksheet.merge_cells(ind2 + 5, ind + 1, ind2 + 5, ind + 4)
          worksheet.add_cell(ind2 + 5, ind + 1, ct.coefficient)
          ind2 += 1
          ind3 += 1
        end
        ind2 = 6
        ind += 4
      end
      ind = 0
      worksheet.add_cell(ind3, ind, "Seuils de complexité")
      worksheet.change_row_bold(ind3, true)
      worksheet.add_cell(ind3 + 1, ind, "Attributs")
      worksheet.sheet_data[ind3 + 1][ind].change_font_bold(true)
      guw_type.guw_type_complexities.each  do |type_attribute_complexity|
        worksheet.merge_cells(ind3, ind + 1, ind3, ind + 4)
        worksheet.add_cell(ind3, ind + 1, type_attribute_complexity.name)
        worksheet.sheet_data[ind3][ind + 1].change_horizontal_alignment('center')
        worksheet.add_cell(ind3 + 1, ind + 1, "Prod")
        worksheet.sheet_data[ind3 + 1][ind + 1].change_horizontal_alignment('center')
        worksheet.merge_cells(ind3 + 1, ind + 2, ind3 + 1, ind + 4)
        worksheet.add_cell(ind3 + 1 , ind + 2, "[    ;    [      /    Poids")
        worksheet.sheet_data[ind3 + 1][ind + 2].change_horizontal_alignment('center')
        ind4 = ind3 + 2
        @guw_model.guw_attributes.order("name ASC").each do |attribute|
          worksheet.add_cell(ind4, 0, attribute.name)
          att_val = Guw::GuwAttributeComplexity.where(guw_type_complexity_id: type_attribute_complexity.id, guw_attribute_id: attribute.id).first
          unless att_val.nil?
            worksheet.add_cell(ind4, ind + 1, att_val.enable_value ? 1 : 0)
            worksheet.add_cell(ind4, ind + 2, att_val.bottom_range)
            worksheet.add_cell(ind4, ind + 3, att_val.top_range)
            worksheet.add_cell(ind4, ind + 4, att_val.value)
          end
          ind4 += 1
        end
        ind += 4
      end
      ind = 0
      ind3 = 5
    end
    send_data(workbook.stream.string, filename: "export.xlsx", type: "application/vnd.ms-excel")
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
