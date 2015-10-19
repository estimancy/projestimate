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
    re = [[],[],[]]
    list_tab = [[],[],[]]
    final_message = []
    tab_error.each_with_index do |row_error ,index|
      if index == 0
        unless row_error.empty?
          re[0] = I18n.t(:Coefficient_of_acquisiton)
          list_tab[0] = row_error
        end
      elsif index == 1
        unless row_error.empty?
          re[1] = I18n.t(:organization_technology)
          list_tab[1] = row_error
        end
      elsif index == 2
        unless row_error.empty?
          re[2] = I18n.t(:pe_attributes)
          list_tab[2] = row_error
        end
      end
    end
    re.each_with_index do |ligne, index|
      unless ligne.empty?
        final_message << " - #{ligne} : #{list_tab[index].join(", ")}"
      end
    end
    unless final_message.empty?
      flash[:error] = I18n.t(:error_warning, parameter: final_message.join("<br/>")).html_safe
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
      flash[:error] = message.join("<br/>").html_safe
    end
  end

  def importxl

    element_found_flag = false
    route_flag = 0
    sheet_error = 0
    critical_flag = true
    action_type_aquisition_flag = false
    action_technologie_flag = false
    action_attribute_flag = false
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
            if worksheet.sheet_name != I18n.t(:is_model)
              route_flag = 5
              break
            end
            if tab[0][1].nil? || tab[0][1].empty?
              route_flag = 2
              break
            end
            @guw_model = Guw::GuwModel.find_by_name(tab[0][1])
            if @guw_model.nil?
              @guw_model = Guw::GuwModel.create(name: tab[0][1],
                                                description: tab[1][1],
                                                three_points_estimation: tab[2][1] == I18n.t(:yes) ? true : false,
                                                retained_size_unit: tab[3][1],
                                                coefficient_label: "type acquisition",
                                                organization_id: @current_organization.id)
              critical_flag = false
            else
              route_flag = 1
              break
            end
          elsif index == 1
            if critical_flag || worksheet.sheet_name != I18n.t(:attribute_description)
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
            if critical_flag || worksheet.sheet_name != I18n.t(:Type_acquisitions)
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
            if critical_flag
              route_flag = 5
              break
            end
            if worksheet.sheet_name != I18n.t(:is_model) && worksheet.sheet_name != I18n.t(:attribute_description) && worksheet.sheet_name != I18n.t(:Type_acquisitions)
              if !tab[0].nil? && !tab[2].nil? && !tab[3].nil? && !tab[1].nil? && !tab[4].nil?
                @guw_type = Guw::GuwType.create(name: worksheet.sheet_name,
                                                description: tab[0][0],
                                                allow_quantity: tab[2][1] == I18n.t(:yes) ? true : false,
                                                allow_retained: tab[1][1] == I18n.t(:yes) ? true : false,
                                                allow_complexity: tab[3][1] == I18n.t(:yes) ? true : false,
                                                allow_criteria: tab[4][1] == I18n.t(:yes) ? true : false,
                                                guw_model_id: @guw_model.id)
                if !tab[8].nil? && !tab[9].nil? && tab[8][0] == I18n.t(:threshold) && !tab[6].empty? && tab[9][0] == I18n.t(:Coefficient_of_acquisiton)
                  while !tab[6][ind].nil?
                    @guw_complexity = Guw::GuwComplexity.create(guw_type_id: @guw_type.id,
                                                               name: tab[6][ind],
                                                               enable_value: tab[8][ind] == I18n.t(:yes) ? true : false,
                                                               bottom_range: tab[8][ind + 1],
                                                               top_range: tab[8][ind + 2],
                                                               weight:  tab[8][ind + 3])
                    @guw_model.guw_work_units.each do |wu|
                      while !tab[ind2].nil? && tab[ind2][0] != wu.name && tab[ind2][0] != I18n.t(:organization_technology)
                        ind2 += 1
                      end
                      if !tab[ind2].nil? && tab[ind2][0] != I18n.t(:organization_technology)
                        Guw::GuwComplexityWorkUnit.create(guw_complexity_id: @guw_complexity.id, guw_work_unit_id: wu.id, value: tab[ind2][ind + 3])
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
                         Guw::GuwComplexityTechnology.create(guw_complexity_id: @guw_complexity.id, organization_technology_id: techno.id, coefficient: tab[ind2][ind + 3])
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
                                                           enable_value: tab[ind3][ind] == I18n.t(:yes) ? true : false,
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
                  action_attribute_flag = true
                end

                unless action_type_aquisition_flag
                  tab_error[0].push(@guw_type.name)
                end
                unless action_technologie_flag
                  tab_error[1].push(@guw_type.name)
                end
                unless action_attribute_flag
                  tab_error[2].push(@guw_type.name)
                end
                action_attribute_flag = false
                action_technologie_flag = false
                action_type_aquisition_flag = false
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
    used_column = []

    worksheet = workbook[0]
    worksheet.sheet_name = I18n.t(:is_model)
    workbook.add_worksheet(I18n.t(:attribute_description))
    workbook.add_worksheet(I18n.t(:Type_acquisitions))
    worksheet.add_cell(0, 0, I18n.t(:model_name))
    worksheet[0][0].change_border(:bottom, 'thin')
    worksheet[0][0].change_border(:right, 'thin')
    worksheet.sheet_data[0][0].change_font_bold(true)

    worksheet.add_cell(0, 1, @guw_model.name)
    worksheet[0][1].change_border(:right, 'thin')
    worksheet[0][1].change_border(:bottom, 'thin')
    worksheet.sheet_data[0][1].change_horizontal_alignment('center')

    worksheet.add_cell(1, 0, I18n.t(:model_description))
    worksheet[1][0].change_border(:right, 'thin')
    worksheet[1][0].change_border(:bottom, 'thin')

    worksheet.add_cell(1, 1, @guw_model.description)
    worksheet[1][1].change_border(:right, 'thin')
    worksheet[1][1].change_border(:bottom, 'thin')

    worksheet.add_cell(2, 0, I18n.t(:three_points_estimation_activities))
    worksheet[2][0].change_border(:right, 'thin')
    worksheet[2][0].change_border(:bottom, 'thin')

    worksheet.add_cell(2, 1, @guw_model.three_points_estimation ? I18n.t(:yes) : I18n.t(:no))
    worksheet[2][1].change_border(:right, 'thin')
    worksheet[2][1].change_border(:bottom, 'thin')
    worksheet.sheet_data[2][1].change_horizontal_alignment('center')

    worksheet.add_cell(3, 0, I18n.t(:retained_size_unit))
    worksheet[3][0].change_border(:right, 'thin')
    worksheet[3][0].change_border(:bottom, 'thin')

    worksheet.add_cell(3, 1, @guw_model.retained_size_unit)
    worksheet[3][1].change_border(:right, 'thin')
    worksheet[3][1].change_border(:bottom, 'thin')

    worksheet.change_column_bold(0,true)
    worksheet.sheet_data[3][1].change_horizontal_alignment('center')
    worksheet.change_row_height(1,deter_size(@guw_model.description) * 13)
    worksheet.change_column_width(0, 38)
    worksheet.change_column_width(1, the_most_largest(@guw_model.description))
    worksheet.add_cell(4, 0, I18n.t(:advice))
    worksheet.add_cell(4, 1, "")

    worksheet.sheet_data[4][0].change_font_bold(true)
    worksheet.merge_cells(4, 0, 4, 1)
    worksheet[4][1].change_border(:right, 'thin')
    worksheet[4][0].change_border(:bottom, 'thin')
    worksheet.change_row_height(4, 25)

    worksheet = workbook[1]

    worksheet.add_cell(0, 0, I18n.t(:pe_attribute_name))
    worksheet[0][0].change_border(:right, 'thin')
    worksheet[0][0].change_border(:bottom, 'thin')

    worksheet.add_cell(0, 1, I18n.t(:description))
    worksheet[0][1].change_border(:right, 'thin')
    worksheet[0][1].change_border(:bottom, 'thin')


    worksheet.change_row_bold(0,true)
    worksheet.change_row_horizontal_alignment(0, 'center')
    @guw_model.guw_attributes.order("name ASC").each_with_index do |attribute, indx|

      worksheet.add_cell(indx + 1, 0, attribute.name)
      worksheet[indx + 1][0].change_border(:right, 'thin')
      worksheet[indx + 1][0].change_border(:bottom, 'thin')

      worksheet.add_cell(indx + 1, 1, attribute.description)
      worksheet[indx + 1][1].change_border(:right, 'thin')
      worksheet[indx + 1][1].change_border(:bottom, 'thin')


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
    worksheet[0][0].change_border(:right, 'thin')
    worksheet[0][0].change_border(:bottom, 'thin')

    worksheet.add_cell(0, 1, I18n.t(:value))
    worksheet[0][1].change_border(:right, 'thin')
    worksheet[0][1].change_border(:bottom, 'thin')

    worksheet.add_cell(0, 2, I18n.t(:display_order))
    worksheet[0][2].change_border(:right, 'thin')
    worksheet[0][2].change_border(:bottom, 'thin')

    worksheet.change_row_horizontal_alignment(0, 'center')
    worksheet.change_column_horizontal_alignment(1, 'center')
    worksheet.change_column_horizontal_alignment(2, 'center')
    worksheet.change_column_width(2, I18n.t(:display_order).size)
    @guw_model.guw_work_units.each_with_index do |aquisitions_type,indx|
      worksheet.add_cell(indx + 1, 0, aquisitions_type.name)

      worksheet[indx + 1][0].change_border(:right, 'thin')
      worksheet[indx + 1][0].change_border(:bottom, 'thin')

      worksheet.add_cell(indx + 1, 1, aquisitions_type.value)
      worksheet[indx + 1][1].change_border(:right, 'thin')
      worksheet[indx + 1][1].change_border(:bottom, 'thin')

      worksheet.add_cell(indx + 1, 2, aquisitions_type.display_order == 0 ? indx : aquisitions_type.display_order)
      worksheet[indx + 1][2].change_border(:right, 'thin')
      worksheet[indx + 1][2].change_border(:bottom, 'thin')

      if ind < aquisitions_type.name.size
        worksheet.change_column_width(0, aquisitions_type.name.size)
        ind = aquisitions_type.name.size
      end
    end

    ind = 0

    worksheet.change_column_horizontal_alignment(1, 'center')
    @guw_types.each do |guw_type|
      worksheet = workbook.add_worksheet(guw_type.name)
      description = Nokogiri::HTML.parse(ActionView::Base.full_sanitizer.sanitize(guw_type.description)).text


      worksheet.add_cell(0, ind, description)
      worksheet[0][0].change_border(:right, 'thin')
      worksheet[0][0].change_border(:bottom, 'thin')
      worksheet.change_row_height(0, deter_size(description) * 15)
      worksheet.change_column_width(0, 65)

      worksheet.add_cell(1, 0, I18n.t(:enable_restraint))
      worksheet[1][0].change_border(:right, 'thin')
      worksheet[1][0].change_border(:bottom, 'thin')
      worksheet.sheet_data[1][0].change_font_bold(true)

      worksheet.add_cell(1, 1,  guw_type.allow_retained ? I18n.t(:yes) : I18n.t(:no))
      worksheet[1][1].change_border(:top, 'thin')
      worksheet[1][1].change_border(:right, 'thin')
      worksheet[1][1].change_border(:bottom, 'thin')
      worksheet.sheet_data[1][1].change_horizontal_alignment('center')

      worksheet.add_cell(2, 0, I18n.t(:enable_amount))
      worksheet[2][0].change_border(:right, 'thin')
      worksheet[2][0].change_border(:bottom, 'thin')
      worksheet.sheet_data[2][0].change_font_bold(true)

      worksheet.add_cell(2, 1,  guw_type.allow_quantity ? I18n.t(:yes) : I18n.t(:no))
      worksheet[2][1].change_border(:right, 'thin')
      worksheet[2][1].change_border(:bottom, 'thin')
      worksheet.sheet_data[2][1].change_horizontal_alignment('center')

      worksheet.add_cell(3, 0,  I18n.t(:enable_complexity))
      worksheet[3][0].change_border(:right, 'thin')
      worksheet[3][0].change_border(:bottom, 'thin')
      worksheet.sheet_data[3][0].change_font_bold(true)

      worksheet.add_cell(3, 1,  guw_type.allow_complexity ? I18n.t(:yes) : I18n.t(:no))
      worksheet[3][1].change_border(:right, 'thin')
      worksheet[3][1].change_border(:bottom, 'thin')
      worksheet.sheet_data[3][1].change_horizontal_alignment('center')

      worksheet.add_cell(4, 0, I18n.t(:enable_counting))
      worksheet[4][0].change_border(:right, 'thin')
      worksheet[4][0].change_border(:bottom, 'thin')
      worksheet.sheet_data[4][0].change_font_bold(true)

      worksheet.add_cell(4, 1,  guw_type.allow_criteria ? I18n.t(:yes) : I18n.t(:no))
      worksheet[4][1].change_border(:right, 'thin')
      worksheet[4][1].change_border(:bottom, 'thin')
      worksheet.sheet_data[4][1].change_horizontal_alignment('center')

      @guw_complexities = guw_type.guw_complexities
      worksheet.add_cell(ind2 , 0,  I18n.t(:UO_type_complexity))
      worksheet[ind2][0].change_border(:top, 'thin')
      worksheet.sheet_data[ind2][0].change_font_bold(true)

      worksheet.add_cell(ind2 + 2, 0, I18n.t(:threshold))
      worksheet[ind2 + 2][0].change_border(:bottom, 'thin')

      worksheet.sheet_data[ind2 + 2][0].change_font_bold(true)
      worksheet.change_row_bold(ind2 + 3,true)
      worksheet.add_cell(ind2 + 3, 0,  I18n.t(:Coefficient_of_acquisiton))
      worksheet[ind2 + 3][0].change_border(:bottom, 'thin')

      @guw_complexities.each do |guw_complexity|

        worksheet.add_cell(ind2 + 1, ind + 1, "Prod")
        worksheet.sheet_data[ind2 + 1][ind + 1].change_horizontal_alignment('center')
        worksheet[ind2 + 1][ind + 1].change_border(:top, 'thin')
        worksheet[ind2 + 1][ind + 1].change_border(:left, 'thin')
        worksheet[ind2 + 1][ind + 1].change_border(:right, 'thin')
        worksheet[ind2 + 1][ind + 1].change_border(:bottom, 'thin')

        worksheet.add_cell(ind2 + 1, ind + 2, "[")
        worksheet.sheet_data[ind2 + 1][ind + 2].change_horizontal_alignment('center')
        worksheet[ind2 + 1][ind + 2].change_border(:top, 'thin')
        worksheet[ind2 + 1][ind + 2].change_border(:right, 'thin')
        worksheet[ind2 + 1][ind + 2].change_border(:bottom, 'thin')

        worksheet.add_cell(ind2 + 1, ind + 3, "[")
        worksheet.sheet_data[ind2 + 1][ind + 3].change_horizontal_alignment('center')
        worksheet[ind2 + 1][ind + 3].change_border(:top, 'thin')
        worksheet[ind2 + 1][ind + 3].change_border(:right, 'thin')
        worksheet[ind2 + 1][ind + 3].change_border(:bottom, 'thin')

        worksheet.add_cell(ind2 + 1, ind + 4, I18n.t(:my_display))
        worksheet.sheet_data[ind2 + 1][ind + 4].change_horizontal_alignment('center')
        worksheet[ind2 + 1][ind + 4].change_border(:top, 'thin')
        worksheet[ind2 + 1][ind + 4].change_border(:right, 'thin')
        worksheet[ind2 + 1][ind + 4].change_border(:bottom, 'thin')

        worksheet.add_cell(ind2, ind + 1, guw_complexity.name)
        worksheet[ind2][ind + 1].change_border(:top, 'thin')
        worksheet[ind2][ind + 1].change_border(:left, 'thin')
        worksheet[ind2][ind + 1].change_border(:right, 'thin')
        worksheet.sheet_data[ind2][ind + 1].change_horizontal_alignment('center')

        worksheet.add_cell(ind2 + 2, ind + 1, guw_complexity.enable_value ? I18n.t(:yes) : I18n.t(:no))
        worksheet[ind2 + 2][ind + 1].change_border(:left, 'thin')
        worksheet[ind2 + 2][ind + 1].change_border(:bottom, 'thin')
        worksheet.sheet_data[ind2 + 2][ind + 1].change_horizontal_alignment('center')

        worksheet.add_cell(ind2 + 2, ind + 2, guw_complexity.bottom_range)
        worksheet[ind2 + 2][ind + 2].change_border(:left, 'thin')
        worksheet[ind2 + 2][ind + 2].change_border(:bottom, 'thin')
        worksheet.sheet_data[ind2 + 2][ind + 2].change_horizontal_alignment('center')

        worksheet.add_cell(ind2 + 2, ind + 3, guw_complexity.top_range)
        worksheet[ind2 + 2][ind + 3].change_border(:left, 'thin')
        worksheet[ind2 + 2][ind + 3].change_border(:bottom, 'thin')
        worksheet.sheet_data[ind2 + 2][ind + 3].change_horizontal_alignment('center')

        worksheet.add_cell(ind2 + 2, ind + 4, guw_complexity.weight)
        worksheet[ind2 + 2][ind + 4].change_border(:left, 'thin')
        worksheet[ind2 + 2][ind + 4].change_border(:bottom, 'thin')
        worksheet[ind2 + 2][ind + 4].change_border(:right, 'thin')
        worksheet.sheet_data[ind2 + 2][ind + 4].change_horizontal_alignment('center')

        guw_complexity.guw_complexity_work_units.each do |guw_complexity_work_unit|
          @guw_work_unit = guw_complexity_work_unit.guw_work_unit
          cu = Guw::GuwComplexityWorkUnit.where(guw_complexity_id: guw_complexity.id, guw_work_unit_id: @guw_work_unit.id).first
          worksheet.add_cell(ind2 + 4, 0, @guw_work_unit.name)
          worksheet[ind2 + 4][0].change_border(:right, 'thin')

          worksheet.add_cell(ind2 + 4, ind + 1, "")
          worksheet.add_cell(ind2 + 4, ind + 2, "")
          worksheet.add_cell(ind2 + 4, ind + 3, "")
          worksheet.add_cell(ind2 + 4, ind + 4, cu.value)
          worksheet.sheet_data[ind2 + 4][ind + 4].change_horizontal_alignment('center')
          worksheet[10][ind + 1].change_border(:top, 'thin')
          worksheet[10][ind + 2].change_border(:top, 'thin')
          worksheet[10][ind + 3].change_border(:top, 'thin')
          worksheet[10][ind + 4].change_border(:top, 'thin')
          worksheet[ind2 + 4][ind + 4].change_border(:right, 'thin')

          ind2 += 1
        end

        worksheet[ind2 + 3][0].change_border(:bottom, 'thin')
        worksheet[ind2 + 3][ind + 1].change_border(:bottom, 'thin')
        worksheet[ind2 + 3][ind + 2].change_border(:bottom, 'thin')
        worksheet[ind2 + 3][ind + 3].change_border(:bottom, 'thin')
        worksheet[ind2 + 3][ind + 4].change_border(:bottom, 'thin')

        worksheet.change_row_bold(ind2 + 4,true)
        worksheet.add_cell(ind2 + 4, 0, I18n.t(:organization_technology))
        worksheet[ind2 + 4][0].change_border(:bottom, 'thin')

        block_it = ind2 + 5

        guw_complexity.guw_complexity_technologies.each do |complexity_technology|
          @guw_organisation_technology = complexity_technology.organization_technology
          ct = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_complexity.id, organization_technology_id: @guw_organisation_technology.id).first
          worksheet.add_cell(ind2 + 5, 0, @guw_organisation_technology.name)
          worksheet[ind2 + 5][0].change_border(:right, 'thin')

          worksheet.add_cell(ind2 + 5, ind + 1, "")
          worksheet.add_cell(ind2 + 5, ind + 2, "")
          worksheet.add_cell(ind2 + 5, ind + 3, "")
          worksheet.add_cell(ind2 + 5, ind + 4, ct.coefficient)
          worksheet.sheet_data[ind2 + 5][ind + 4].change_horizontal_alignment('center')
          worksheet[block_it][ind + 1].change_border(:top, 'thin')
          worksheet[block_it][ind + 2].change_border(:top, 'thin')
          worksheet[block_it][ind + 3].change_border(:top, 'thin')
          worksheet[block_it][ind + 4].change_border(:top, 'thin')
          worksheet[ind2 + 5][ind + 4].change_border(:right, 'thin')

          ind2 += 1
        end
        worksheet[ind2 + 4][0].change_border(:bottom, 'thin')
        worksheet[ind2 + 4][ind + 1].change_border(:bottom, 'thin')
        worksheet[ind2 + 4][ind + 2].change_border(:bottom, 'thin')
        worksheet[ind2 + 4][ind + 3].change_border(:bottom, 'thin')
        worksheet[ind2 + 4][ind + 4].change_border(:bottom, 'thin')

        if ind3 < ind2
          ind3 += (ind2 + 1)
        end
        ind2 = 6
        ind += 4
      end
      ind = 0
      worksheet.add_cell(ind3, ind, I18n.t(:complexity_threshold))
      worksheet.sheet_data[ind3][ind].change_font_bold(true)
      worksheet[ind3][ind].change_border(:top, 'thin')

      worksheet.add_cell(ind3 + 1, ind, I18n.t(:pe_attributes))
      worksheet.sheet_data[ind3 + 1][ind].change_font_bold(true)
      worksheet[ind3 + 1][ind].change_border(:bottom, 'thin')

      guw_type.guw_type_complexities.each  do |type_attribute_complexity|
        worksheet.add_cell(ind3, ind + 1, type_attribute_complexity.name)
        worksheet[ind3][ind + 1].change_border(:top, 'thin')
        worksheet[ind3][ind + 1].change_border(:right, 'thin')
        worksheet[ind3][ind + 1].change_border(:left, 'thin')
        worksheet.sheet_data[ind3][ind + 1].change_horizontal_alignment('center')

        worksheet.add_cell(ind3 + 1, ind + 1, "Prod")
        worksheet.sheet_data[ind3 + 1][ind + 1].change_horizontal_alignment('center')
        worksheet[ind3 + 1][ind + 1].change_border(:top, 'thin')
        worksheet[ind3 + 1][ind + 1].change_border(:bottom, 'thin')
        worksheet[ind3 + 1][ind + 1].change_border(:left, 'thin')

        worksheet.add_cell(ind3 + 1, ind + 2, "[")
        worksheet.sheet_data[ind3 + 1][ind + 2].change_horizontal_alignment('center')
        worksheet[ind3 + 1][ind + 2].change_border(:top, 'thin')
        worksheet[ind3 + 1][ind + 2].change_border(:bottom, 'thin')
        worksheet[ind3 + 1][ind + 2].change_border(:left, 'thin')

        worksheet.add_cell(ind3 + 1, ind + 3, "[")
        worksheet.sheet_data[ind3 + 1][ind + 3].change_horizontal_alignment('center')
        worksheet[ind3 + 1][ind + 3].change_border(:top, 'thin')
        worksheet[ind3 + 1][ind + 3].change_border(:bottom, 'thin')
        worksheet[ind3 + 1][ind + 3].change_border(:left, 'thin')

        worksheet.add_cell(ind3 + 1, ind + 4, I18n.t(:my_display))
        worksheet.sheet_data[ind3 + 1][ind + 4].change_horizontal_alignment('center')
        worksheet[ind3 + 1][ind + 4].change_border(:top, 'thin')
        worksheet[ind3 + 1][ind + 4].change_border(:bottom, 'thin')
        worksheet[ind3 + 1][ind + 4].change_border(:left, 'thin')
        worksheet[ind3 + 1][ind + 4].change_border(:right, 'thin')

        ind4 = ind3 + 2
        @guw_model.guw_attributes.order("name ASC").each do |attribute|
          worksheet.add_cell(ind4, 0, attribute.name)
          worksheet[ind4][0].change_border(:right, 'thin')

          att_val = Guw::GuwAttributeComplexity.where(guw_type_complexity_id: type_attribute_complexity.id, guw_attribute_id: attribute.id).first
          unless att_val.nil?
            worksheet.add_cell(ind4, ind + 1, att_val.enable_value ? I18n.t(:yes) : I18n.t(:no))
            worksheet[ind4][ind + 1].change_border(:right, 'thin')
            worksheet.sheet_data[ind4][ind + 1].change_horizontal_alignment('center')


            worksheet.add_cell(ind4, ind + 2, att_val.bottom_range)
            worksheet[ind4][ind + 2].change_border(:right, 'thin')
            worksheet.sheet_data[ind4][ind + 2].change_horizontal_alignment('center')

            worksheet.add_cell(ind4, ind + 3, att_val.top_range)
            worksheet[ind4][ind + 3].change_border(:right, 'thin')
            worksheet.sheet_data[ind4][ind + 3].change_horizontal_alignment('center')

            worksheet.add_cell(ind4, ind + 4, att_val.value)
            worksheet[ind4][ind + 4].change_border(:right, 'thin')
            worksheet.sheet_data[ind4][ind + 4].change_horizontal_alignment('center')

          end
          ind4 += 1
        end

        worksheet[ind4 - 1][0].change_border(:bottom, 'thin')
        worksheet[ind4 - 1][ind + 1].change_border(:bottom, 'thin')
        worksheet[ind4 - 1][ind + 2].change_border(:bottom, 'thin')
        worksheet[ind4 - 1][ind + 3].change_border(:bottom, 'thin')
        worksheet[ind4 - 1][ind + 4].change_border(:bottom, 'thin')

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
    set_page_title I18n.t(:new_UO_model)
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])
    @organization = @guw_model.organization
    set_page_title I18n.t(:edit_project_element_name, parameter: @guw_model.name)
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
    ind = 1
    tab_size = [I18n.t(:estimation).length,
                I18n.t(:version).length,
                I18n.t(:group).length,
                I18n.t(:selected).length,
                I18n.t(:name).length,
                I18n.t(:description).length,
                I18n.t(:work_unit_type).length,
                @guw_model.coefficient_label.length,
                I18n.t(:organization_technology).length,
                I18n.t(:quantity).length,
                I18n.t(:tracability).length,
                I18n.t(:cotation).length,
                I18n.t(:results).length,
                I18n.t(:retained_result).length,
                I18n.t(:pe_attribute_name).length,
                I18n.t(:low).length,
                I18n.t(:likely).length,
                I18n.t(:high).length]

    worksheet.change_row_bold(0,true)
    worksheet.add_cell(0, 0, I18n.t(:estimation))
    worksheet.change_column_width(0, tab_size[0])
    worksheet.add_cell(0, 1,I18n.t(:version))
    worksheet.change_column_width(1, tab_size[1])
    worksheet.add_cell(0, 2, I18n.t(:group))
    worksheet.change_column_width(2, tab_size[2])
    worksheet.add_cell(0, 3,I18n.t(:selected))
    worksheet.change_column_width(3, tab_size[3])
    worksheet.add_cell(0, 4,I18n.t(:name))
    worksheet.add_cell(0, 5, I18n.t(:description))
    worksheet.change_column_width(5, tab_size[5])
    worksheet.add_cell(0, 6, I18n.t(:work_unit_type))
    worksheet.change_column_width(6, tab_size[6])
    worksheet.add_cell(0, 7,@guw_model.coefficient_label)
    worksheet.change_column_width(7, tab_size[7])
    worksheet.add_cell(0, 8,I18n.t(:organization_technology))
    worksheet.change_column_width(8,tab_size[8])
    worksheet.add_cell(0, 9, I18n.t(:quantity))
    worksheet.change_column_width(9, tab_size[9])
    worksheet.add_cell(0, 10,I18n.t(:tracability))
    worksheet.change_column_width(10, tab_size[10])
    worksheet.add_cell(0, 11, I18n.t(:cotation))
    worksheet.change_column_width(11, tab_size[11])
    worksheet.add_cell(0, 12, I18n.t(:results))
    worksheet.change_column_width(12, tab_size[12])
    worksheet.add_cell(0, 13, I18n.t(:retained_result))
    worksheet.change_column_width(13, tab_size[13])
    worksheet.add_cell(0, 14, I18n.t(:pe_attribute_name))
    worksheet.change_column_width(14, tab_size[14])
    worksheet.add_cell(0, 15, I18n.t(:low))
    worksheet.change_column_width(15, tab_size[15])
    worksheet.add_cell(0, 16, I18n.t(:likely))
    worksheet.change_column_width(16, tab_size[16])
    worksheet.add_cell(0, 17, I18n.t(:high))
    worksheet.change_column_width(17, tab_size[17])
    @guw_unit_of_works.each do |guow|
      if guow.off_line
        cplx = "HSAT"
      elsif guow.off_line_uo
        cplx = "HSUO"
      elsif guow.guw_complexity.nil?
        cplx = "-"
      else
        cplx = guow.guw_complexity.name
      end
      @guw_model.guw_attributes.all.each do |gac|
        finder = Guw::GuwUnitOfWorkAttribute.where(guw_unit_of_work_id: guow.id, guw_attribute_id: gac.id, guw_type_id: guow.guw_type.id).first
        unless finder.nil?
          sum_range = gac.guw_attribute_complexities.where(guw_type_id: guow.guw_type.id).map{|i| [i.bottom_range, i.top_range]}.flatten.compact
          unless sum_range.nil? || sum_range.blank? || sum_range == 0
            worksheet.add_cell(ind, 0, current_module_project.project.title)
            tab_size[0]= tab_size[0] < current_module_project.project.title.length ? current_module_project.project.title.length : tab_size[0]
            worksheet.change_column_width(0, tab_size[0])
            worksheet.add_cell(ind, 1, current_module_project.project.version)
            worksheet.add_cell(ind, 2, guow.guw_unit_of_work_group.name)
            tab_size[2] = tab_size[2] < guow.guw_unit_of_work_group.name.length ? guow.guw_unit_of_work_group.name.length : tab_size[2]
            worksheet.change_column_width(2, tab_size[2])
            worksheet.add_cell(ind, 3, guow.selected ? I18n.t(:yes) : I18n.t(:no))
            worksheet.add_cell(ind, 4, guow.name)
            tab_size[4] = tab_size[4] < guow.name.length ? guow.name.length : tab_size[4]
            worksheet.change_column_width(4, tab_size[4])
            worksheet.add_cell(ind, 5, guow.comments)
            worksheet.add_cell(ind, 6, guow.guw_type.name)
            tab_size[6] = tab_size[6] < guow.guw_type.name.to_s.length ? guow.guw_type.name.to_s.length : tab_size[6]
            worksheet.change_column_width(6, tab_size[6])
            worksheet.add_cell(ind, 7, guow.guw_work_unit)
            worksheet.add_cell(ind, 8, guow.organization_technology)
            tab_size[8] = tab_size[8] < guow.organization_technology.to_s.length ? guow.organization_technology.to_s.length : tab_size[8]
            worksheet.change_column_width(8, tab_size[8])
            worksheet.add_cell(ind, 9, guow.quantity)
            worksheet.add_cell(ind, 10, guow.tracking)
            worksheet.add_cell(ind, 11, cplx)
            tab_size[11] = tab_size[11] < cplx.length ? cplx.length : tab_size[11]
            worksheet.change_column_width(11, tab_size[11])
            worksheet.add_cell(ind, 12, guow.effort)
            worksheet.add_cell(ind, 13, guow.ajusted_effort)
            worksheet.add_cell(ind, 14, finder.guw_attribute.name)
            tab_size[14] = tab_size[14] < finder.guw_attribute.name.length ? finder.guw_attribute.name.length : tab_size[14]
            worksheet.change_column_width(14, tab_size[14])
            worksheet.add_cell(ind, 15, finder.low ? finder.low : "N/A")
            worksheet.add_cell(ind, 16, finder.most_likely ? finder.most_likely : "N/A")
            worksheet.add_cell(ind, 17, finder.high ? finder.high : "N/A")
            ind += 1
          end
        end
      end
    end
  send_data(workbook.stream.string, filename: "export-uo-#{Time.now.strftime('%Y-%m-%d_%H-%M')}.xlsx", type: "application/vnd.ms-excel")
  end

  def my_verrif_tab_error(tab_error, indexing_field_error)

    final_mess = []

    tab_error.each_with_index  do |error_type, index|
      if error_type[0] == true
        case
          when index == 0
            final_mess << I18n.t(:route_flag_error_8, mess_error: error_type[1..error_type.size - 1].join(", "))
          when index == 1
            final_mess << I18n.t(:route_flag_error_9, mess_error: error_type[1..error_type.size - 1].join(", "))
          when index == 2
            final_mess << I18n.t(:route_flag_error_10,mess_error: error_type[1..error_type.size - 1].join(", "))
          when index == 3
            final_mess << I18n.t(:route_flag_error_11,mess_error: error_type[1..error_type.size - 1].join(", "))
          when index == 4
            final_mess << I18n.t(:route_flag_error_12,mess_error: error_type[1..error_type.size - 1].join(", "))
          else
            nothing = 42
        end
      end
    end
    indexing_field_error.each_with_index  do |error_type, index|
      if error_type.size > 1
        case
          when index == 0
            final_mess << I18n.t(route_flag_error_13, mess_error: error_type[1..error_type.size - 1].join(", "))
          when index == 1
            final_mess << I18n.t(route_flag_error_14, mess_error: error_type[1..error_type.size - 1].join(", "))
          when index == 2
            final_mess << I18n.t(route_flag_error_15, mess_error: error_type[1..error_type.size - 1].join(", "))
          when index == 3
            final_mess << I18n.t(route_flag_error_16, mess_error: error_type[1..error_type.size - 1].join(", "))
          else
            nothing = 42
        end
      end
    end
      unless final_mess.empty?
      flash[:error] = final_mess.join("<br/>").html_safe
    end
  end

  def import_myexport

    @guw_model = current_module_project.guw_model
    @component = current_component
    ind = 0
    ok = false
    already_exist = ["first"]
    first = false
    type_save = 0
    guw_uow_save = 0
    gac_save = 0
    tab_error = [[false], [false], [false], [false], [false]]
    indexing_field_error = [[false],[false],[false],[false]]

    if !params[:file].nil? &&
        (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      worksheet =workbook[0]
      tab = worksheet.extract_data

      tab.each_with_index  do |row, index|
        if index > 0
          if row[4] && row[2] && row[6] && row[7] && row[8]  && !row[4].empty? &&  !row[2].empty? && !row[6].empty? && !row[7].empty? && !row[8].empty?
            guw_uow_group = Guw::GuwUnitOfWorkGroup.where(name: row[2],
                                                          module_project_id: current_module_project.id,
                                                          pbs_project_element_id: @component.id,).first_or_create
            my_order = Guw::GuwUnitOfWork.count('id' , :conditions => "module_project_id = #{current_module_project.id} AND pbs_project_element_id = #{@component.id} AND guw_unit_of_work_group_id = #{guw_uow_group.id}  AND guw_model_id = #{@guw_model.id}")
            if already_exist.join(",").include?(row[0..13].join(","))
              @guw_model.guw_attributes.all.each do |gac|
                if gac.name == row[14]
                  finder = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: type_save,
                                                             guw_unit_of_work_id: guw_uow_save,
                                                             guw_attribute_id: gac.id).first_or_create
                  finder.low = row[15] == "N/A" ? nil : row[15]
                  finder.most_likely = row[16] == "N/A" ? nil : row[16]
                  finder.high = row[17] == "N/A" ? nil : row[17]
                  finder.save
                  break
                end
              end
            else
                guw_uow = Guw::GuwUnitOfWork.new(selected: row[3] == "Oui" ? true : false,
                                                 name: row[4],
                                                 comments: row[5],
                                                 guw_unit_of_work_group_id: guw_uow_group.id,
                                                 module_project_id: current_module_project.id,
                                                 pbs_project_element_id: @component.id,
                                                 guw_model_id: @guw_model.id,
                                                 display_order: my_order,
                                                 tracking: row[10], quantity: row[9],
                                                 effort: row[12].nil? ? 0 : row[12],
                                                 ajusted_effort: row[13].nil? ? 0 : row[13])
                @guw_model.guw_work_units.each do |wu|
                  if wu.name == row[7]
                    guw_uow.guw_work_unit_id = wu.id
                    ind += 1
                    indexing_field_error[1][0] = true
                    break
                  end
                  indexing_field_error[1][0] = false
                end
                unless indexing_field_error[1][0]
                  indexing_field_error[1] << index
                end
                @guw_model.guw_types.each do |type|
                  if row[6] == type.name
                    guw_uow.guw_type_id = type.id
                    indexing_field_error[0][0] = true
                    @guw_model.guw_attributes.all.each do |gac|
                      if gac.name == row[14]
                        gac_save = gac.id
                        type_save = type.id
                        break
                      end
                    end
                    if !row[11].nil? && row[11] != "-"
                      type.guw_complexities.each do |complexity|
                        if row[11] == complexity.name
                          guw_uow.guw_complexity_id = complexity.id
                          indexing_field_error[3][0] = true
                          break
                        end
                        indexing_field_error[3][0] = false
                      end
                      unless indexing_field_error[3][0]
                        indexing_field_error[3] << index
                      end
                    end
                    type.guw_complexity_technologies.each do |techno|
                      if row[8] == techno.organization_technology.name
                        guw_uow.organization_technology_id = techno.organization_technology.id
                        ind += 1
                        indexing_field_error[2][0] = true
                        break
                      end
                      indexing_field_error[2][0] = false
                    end

                    unless indexing_field_error[2][0]
                      indexing_field_error[2] << index
                    end

                    ind += 1
                    break
                  end
                  indexing_field_error[0][0] = false
                end
                unless indexing_field_error[0][0]
                  indexing_field_error[0] << index
                end
                if ind == 3
                  guw_uow.save
                  finder = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: type_save,
                                                             guw_unit_of_work_id: guw_uow.id,
                                                             guw_attribute_id: gac_save).first_or_create
                  guw_uow_save = guw_uow.id
                  finder.low = row[15] == "N/A" ? nil : row[15]
                  finder.most_likely = row[16] == "N/A" ? nil : row[16]
                  finder.high = row[17] == "N/A" ? nil : row[17]
                  finder.save
                else
                  tab_error << index
                end
                ind = 0
                already_exist = row
            end
          else
            if row[4].nil? || row[4].empty?
              tab_error[0][0] = true
              tab_error[0] << index
            end
            if row[2].nil? || row[2].empty?
              tab_error[1][0] = true
              tab_error[1] << index
            end
            if row[6].nil? || row[6].empty?
              tab_error[2][0] = true
              tab_error[2] << index
            end
            if row[7].nil? || row[7].empty?
              tab_error[3][0] = true
              tab_error[3] << index
            end
            if row[8].nil? || row[8].empty?
              tab_error[4][0] = true
              tab_error[4] << index
            end
          end
        end
        ok = true
      end
    end
    my_verrif_tab_error(tab_error, indexing_field_error)
    if ok
      flash[:notice] = I18n.t(:importation_sucess_uo)
    else ok
      flash[:error] = I18n.t(:route_flag_error_4)
    end
    redirect_to :back
  end

end
