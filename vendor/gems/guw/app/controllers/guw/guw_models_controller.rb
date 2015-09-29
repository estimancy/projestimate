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

  def bug_tracker (tab_error)
    re = []
    flag_for_show = false
    tab_error.each_with_index do |row_error ,index|
      if index == 0
        if !row_error.empty?
          re << I18n.t(:Coefficient_of_acquisiton)
          flag_for_show = true
        end
      elsif index == 1
        if !row_error.empty?
          re << I18n.t(:organization_technology)
          flag_for_show = true
        end
      elsif index == 2
        if !row_error.empty?
          re << I18n.t(:pe_attributes)
          flag_for_show = true
        end
      end
      if flag_for_show == true
        flash[:error] = I18n.t(:error_warning, parameter_1: re.join(", "), parameter_2: row_error.join(", "))
      end
    end
  end

  def redirect_to_good_path(route_flag, index)
    message = []
    if route_flag == 1
      message << I18n.t(:route_flag_error_1)
    elsif route_flag == 2
     message << I18n.t(:route_flag_error_2)
    elsif route_flag == 3
      message << I18n.t(:route_flag_error_3)
    elsif route_flag == 4
      message << I18n.t(:route_flag_error_4)
    elsif route_flag == 5
      message <<  I18n.t(:route_flag_error_5)
   elsif route_flag == 6
      message <<  I18n.t(:route_flag_error_6, ind: index)
    elsif route_flag == 7
      message << I18n.t(:route_flag_error_7)
    end
      if route_flag == 7 || route_flag == 6 || route_flag == 0
        redirect_to "/organizations/#{@current_organization.id}/module_estimation"
      else
        redirect_to :back
      end
    if route_flag == 0
      flash[:notice] = I18n.t(:importation_success)
    else
      flash[:error] = message.join(" ")
    end
  end

  def importxl

    element_found_flag = false
    route_flag = 0
    sheet_error = 0
    critical_flag = true
    action_type_aquisition_flag = false
    action_technologie_flag = false
    action_Attribute_flag = false
    tab_error = [[], [], []]
    ind = 1
    ind2 = 10
    ind3 = 0
    save_position = 0
    if !params[:file].nil? &&
        (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      @workbook = RubyXL::Parser.parse(params[:file].path)
      @workbook.each_with_index do |worksheet, index|
       tab = worksheet.extract_data
       if !tab.empty?
          if index == 0
            if tab[0][1].nil? || tab[0][1].empty?
              route_flag = 2
              break
            end
            @guw_model = Guw::GuwModel.find_by_name(tab[0][1])
            if @guw_model.nil?
              @guw_model = Guw::GuwModel.create(name: tab[0][1],
                                             description: tab[1][1],
                                             three_points_estimation: tab[2][1] == 1 ? true : false,
                                             retained_size_unit: tab[3][1],
                                             organization_id: @current_organization.id)
              critical_flag = false
            else
              route_flag = 1
              break
            end
          elsif index == 1
            if critical_flag == true
              route_flag = 5
              break
            end
            tab.each_with_index do |row, index|
              if index != 0 && !row.nil?
               Guw::GuwAttribute.create(name: row[0],
                                        description: row[1],
                                        guw_model_id: @guw_model.id)
              end
            end
          elsif index == 2
            if critical_flag == true
              route_flag = 5
              break
            end
            tab.each_with_index do |row, index|
              if index != 0 && !row.nil?
                 Guw::GuwWorkUnit.create(name:row[0],
                                         value: row[1],
                                         display_order: row[2],
                                         guw_model_id: @guw_model.id)
              end
            end
          else
            if critical_flag == true
              route_flag = 5
              break
            end
            if worksheet.sheet_name != I18n.t(:is_model) && worksheet.sheet_name != I18n.t(:attribute_description) && worksheet.sheet_name != I18n.t(:Type_acquisitions)
              if !tab[0].nil? && !tab[2].nil? && !tab[3].nil? && !tab[1].nil? && !tab[4].nil?
                @guw_type = Guw::GuwType.create(name: worksheet.sheet_name,
                                                description: tab[0][0],
                                                allow_quantity: tab[2][1] == 1 ? true : false,
                                                allow_retained: tab[1][1] == 1 ? true : false,
                                                allow_complexity: tab[3][1] == 1 ? true : false,
                                                allow_criteria: tab[4][1] == 1 ? true : false,
                                                guw_model_id: @guw_model.id)
                if !tab[8].nil? && !tab[9].nil? && tab[8][0] == I18n.t(:threshold) && !tab[6].empty? && tab[9][0] == I18n.t(:Coefficient_of_acquisiton)
                  while !tab[6][ind].nil?
                    @guw_complexity = Guw::GuwComplexity.create(guw_type_id: @guw_type.id,
                                                               name: tab[6][ind],
                                                               enable_value: tab[8][ind] == 1 ? true : false,
                                                               bottom_range: tab[8][ind + 1],
                                                               top_range: tab[8][ind + 2],
                                                               weight:  tab[8][ind + 3])
                    @guw_model.guw_work_units.each do |wu|
                      while !tab[ind2].nil? && tab[ind2][0] != wu.name && tab[ind2][0] != I18n.t(:organization_technology)
                        ind2 += 1
                      end
                      if !tab[ind2].nil? && tab[ind2][0] != I18n.t(:organization_technology)
                        Guw::GuwComplexityWorkUnit.create(guw_complexity_id: @guw_complexity.id, guw_work_unit_id: wu.id, value: tab[ind2][ind])
                      elsif tab[ind2].nil?
                        route_flag = 3
                        break
                      end
                      ind2 = 10
                      action_type_aquisition_flag = true
                    end
                    if tab[ind2].nil? || route_flag == 3
                      route_flag = 3
                      break
                    end
                    while !tab[ind2].nil? && tab[ind2][0] != I18n.t(:organization_technology)
                      ind2 += 1
                    end
                    ind3 = ind2
                    if !tab[ind2].nil? && tab[ind2][0] == I18n.t(:organization_technology)
                      @current_organization.organization_technologies.each do |techno|
                       while !tab[ind2].nil? && tab[ind2][0] != techno.name
                         ind2 += 1
                       end
                       if !tab[ind2].nil?
                         Guw::GuwComplexityTechnology.create(guw_complexity_id: @guw_complexity.id, organization_technology_id: techno.id, coefficient: tab[ind2][ind])
                       end
                       ind2 = ind3
                      end
                      if save_position == 0
                        while !tab[ind2].nil?
                          ind2 += 1
                        end
                        save_position = ind2 + 1
                      end
                      action_technologie_flag = true
                    end
                    ind2 = 10
                    ind += 4
                  end
                  ind = 1
                end
                if !tab[save_position].nil? && tab[save_position][0] == I18n.t(:complexity_threshold) && tab[save_position + 1][0] == I18n.t(:pe_attributes)
                  ind3 = save_position + 2
                  ind = 1
                  while !tab[save_position][ind].nil?
                   @guw_att_complexity =  Guw::GuwTypeComplexity.create(guw_type_id: @guw_type.id, name: tab[save_position][ind], value: 4)
                    @guw_model.guw_attributes.each do |att|
                      while !tab[ind3].nil? && tab[ind3][0] != att.name
                        ind3 += 1
                      end
                      if !tab[ind3].nil?
                        toto = Guw::GuwAttributeComplexity.create(guw_type_complexity_id: @guw_att_complexity.id,
                                                           guw_attribute_id: att.id,
                                                           guw_type_id: @guw_type.id,
                                                           enable_value: tab[ind3][ind] == 0 ? false : true,
                                                           bottom_range: tab[ind3][ind + 1],
                                                           top_range: tab[ind3][ind + 2],
                                                           value: tab[ind3][ind + 3])
                      end
                      ind3 = save_position + 2
                    end
                   ind += 4
                  end
                  ind3 = 0
                  ind = 1
                  action_Attribute_flag = true
                end

                if action_type_aquisition_flag == false
                  tab_error[0].push(@guw_type.name)
                else
                  action_type_aquisition_flag = false
                end
                if action_technologie_flag == false
                  tab_error[1].push(@guw_type.name)
                else
                  action_technologie_flag = false
                end
                if action_Attribute_flag == false
                  tab_error[2].push(@guw_type.name)
                else
                  action_Attribute_flag = false
                end
              else
                route_flag = 6
                sheet_error += 1
              end
            else
              route_flag = 7
              break
            end
          end
        else
          route_flag = 6
          sheet_error += 1
        end
        save_position = 0
        end
      else
        route_flag = 4
    end
    redirect_to_good_path(route_flag, sheet_error)
    bug_tracker(tab_error)
  end

  def deter_size(my_string)
    ind = 0
    len = 0
    if my_string.nil?
      return 1
    end
    while my_string[ind]
      if my_string[ind] == "\n"
        len += 1
      end
      ind += 1
    end
    len
  end

  def the_most_largest(my_string)
    ind = 0
    len = 0
    len2 = 0
    if my_string.nil?
      return 1
    end
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
    len2
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
    worksheet.sheet_name = I18n.t(:is_model)
    workbook.add_worksheet(I18n.t(:attribute_description))
    workbook.add_worksheet(I18n.t(:Type_acquisitions))
    worksheet.add_cell(0, 0, I18n.t(:model_name))
    worksheet.sheet_data[0][0].change_font_bold(true)
    worksheet.add_cell(0, 1, @guw_model.name)
    worksheet.sheet_data[0][1].change_horizontal_alignment('center')
    worksheet.add_cell(1, 0, I18n.t(:model_description))
    worksheet.add_cell(1, 1, @guw_model.description)
    worksheet.add_cell(2, 0, I18n.t(:three_points_estimation_activities))
    worksheet.add_cell(2, 1, @guw_model.three_points_estimation ? 1 : 0)
    worksheet.sheet_data[2][1].change_horizontal_alignment('center')
    worksheet.add_cell(3, 0, I18n.t(:retained_size_unit))
    worksheet.add_cell(3, 1, @guw_model.retained_size_unit)
    worksheet.change_column_bold(0,true)
    worksheet.sheet_data[3][1].change_horizontal_alignment('center')
    worksheet.change_row_height(1,deter_size(@guw_model.description) * 13)
    worksheet.change_column_width(0, 38)
    worksheet.change_column_width(1, the_most_largest(@guw_model.description))
    worksheet.add_cell(4, 0, I18n.t(:advice))
    worksheet.sheet_data[4][0].change_font_bold(true)
    worksheet.merge_cells(4, 0, 4, 1)
    worksheet.change_row_height(4, 25)


    worksheet = workbook[1]
    worksheet.add_cell(0, 0, I18n.t(:pe_attribute_name))
    worksheet.add_cell(0, 1, I18n.t(:description))
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
    worksheet.add_cell(0, 0, I18n.t(:name))
    worksheet.add_cell(0, 1, I18n.t(:value))
    worksheet.add_cell(0, 2, I18n.t(:display_order))
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
      description = Nokogiri::HTML.parse(ActionView::Base.full_sanitizer.sanitize(guw_type.description)).text
      worksheet.add_cell(0, ind, description)
      worksheet.change_row_height(0, deter_size(description) * 15)
      worksheet.change_column_width(0, 65)


      worksheet.add_cell(1, 0, I18n.t(:enable_restraint))
      worksheet.sheet_data[1][0].change_font_bold(true)
      worksheet.add_cell(1, 1,  guw_type.allow_retained ? 1 : 0)

      worksheet.add_cell(2, 0, I18n.t(:enable_amount))
      worksheet.sheet_data[2][0].change_font_bold(true)
      worksheet.add_cell(2, 1,  guw_type.allow_quantity ? 1 : 0)

      worksheet.add_cell(3, 0,  I18n.t(:enable_complexity))
      worksheet.sheet_data[3][0].change_font_bold(true)
      worksheet.add_cell(3, 1,  guw_type.allow_complexity ? 1 : 0)

      worksheet.add_cell(4, 0, I18n.t(:enable_counting))
      worksheet.sheet_data[4][0].change_font_bold(true)
      worksheet.add_cell(4, 1,  guw_type.allow_criteria ? 1 : 0)

      @guw_complexities = guw_type.guw_complexities
      worksheet.add_cell(ind2 , 0,  I18n.t(:UO_type_complexity))
      worksheet.sheet_data[ind2][0].change_font_bold(true)
      worksheet.sheet_data[ind2][0].change_horizontal_alignment('left')
      worksheet.change_row_horizontal_alignment( ind2 + 1, 'center')
      worksheet.change_row_bold(ind2 + 3,true)
      worksheet.add_cell(ind2 + 3, 0,  I18n.t(:Coefficient_of_acquisiton))
      worksheet.add_cell(ind2 + 2, 0, I18n.t(:threshold))
      worksheet.sheet_data[ind2 + 2][0].change_font_bold(true)
      @guw_complexities.each do |guw_complexity|
        worksheet.add_cell(ind2 + 1, ind + 2, I18n.t(:my_display))
        worksheet.add_cell(ind2 + 1, ind + 1, "Prod")
        worksheet.merge_cells(0, 0, 0, ind + 4)
        worksheet.merge_cells(ind2, ind + 1, ind2, ind + 4)
        worksheet.merge_cells(ind2 + 3, 0, ind2 + 3, ind + 4)
        worksheet.merge_cells(ind2 + 1, ind + 2, ind2 + 1, ind + 4)
        worksheet.add_cell(ind2, ind + 1, guw_complexity.name)
        worksheet.sheet_data[ind2][ind + 1].change_horizontal_alignment('center')
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
        worksheet.add_cell(ind2 + 4, 0, I18n.t(:organization_technology))
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
      worksheet.add_cell(ind3, ind, I18n.t(:complexity_threshold))
      worksheet.sheet_data[ind3][ind].change_font_bold(true)
      worksheet.add_cell(ind3 + 1, ind, I18n.t(:pe_attributes))
      worksheet.sheet_data[ind3 + 1][ind].change_font_bold(true)
      guw_type.guw_type_complexities.each  do |type_attribute_complexity|
        worksheet.merge_cells(ind3, ind + 1, ind3, ind + 4)
        worksheet.add_cell(ind3, ind + 1, type_attribute_complexity.name)
        worksheet.sheet_data[ind3][ind + 1].change_horizontal_alignment('center')
        worksheet.add_cell(ind3 + 1, ind + 1, "Prod")
        worksheet.sheet_data[ind3 + 1][ind + 1].change_horizontal_alignment('center')
        worksheet.merge_cells(ind3 + 1, ind + 2, ind3 + 1, ind + 4)
        worksheet.add_cell(ind3 + 1 , ind + 2, I18n.t(:my_display))
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
    send_data(workbook.stream.string, filename: "#{@guw_model.name.gsub(" ", "_")}-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
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
    set_page_title 'New UO model'
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])
    @organization = @guw_model.organization
    set_page_title "Edit #{@guw_model.organization}"
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
