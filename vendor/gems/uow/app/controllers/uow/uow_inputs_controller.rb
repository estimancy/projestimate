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

class Uow::UowInputsController < ApplicationController

  before_filter :set_pemodule, only: [:index, :new_item, :remove_item, :import, :save_uow]

  def index
  end

  def new_item
    @input = UowInput.new(module_project_id: @module_project.id, pbs_project_element_id: @pbs.id, display_order: params[:index].to_i + 1)
    @input.save(validate: false)
    @uow_inputs = UowInput.where(module_project_id: @module_project, pbs_project_element_id: @pbs.id).order("display_order ASC").all
    @uow_inputs.each_with_index do |input, i|
      input.display_order = i
      input.save(validate: false)
    end
    @count = @uow_inputs.count.to_i
    @index = params[:index].to_i

    redirect_to main_app.dashboard_path(@project)
  end

  def remove_item
    @deleted_input_id = params[:input_id]
    @input = UowInput.find(params[:input_id])
    @input.delete
    @uow_inputs = UowInput.where(module_project_id: @module_project, pbs_project_element_id: @pbs.id).order("display_order ASC").all
    @uow_inputs.each_with_index do |input, i|
      input.display_order = i
      input.save(validate: false)
    end
    @input_index = params['row_index']

    redirect_to main_app.dashboard_path(@project)
  end

  def export
    csv_string = UowInput::export(params[:module_project_id], params[:pbs_id])
    send_data(csv_string, :type => 'text/csv; header=present', :disposition => "attachment; filename=uo.csv")
  end

  def import
    csv_string = UowInput::import(params[:file], params[:separator], params[:encoding], current_component, @module_project)
    redirect_to main_app.root_url
  end

  def save_uow
    @gross = []

    params[:input_id].keys.each do |r|
      input = UowInput.where(id: params[:input_id]["#{r}"].to_i).first
      input.name = params[:name]["#{r}"]
      input.module_project_id = current_module_project.id
      input.pbs_project_element_id = current_component.id
      input.technology_id = params[:technology]["#{r}"]
      input.unit_of_work_id = params[:uow]["#{r}"]
      input.complexity_id = params[:complexity]["#{r}"] if params[:complexity]
      input.size_unit_type_id = params[:size_unit_type]["#{r}"] if params[:size_unit_type]
      input.size_low = params[:size_low]["#{r}"]
      input.size_most_likely = params[:size_most_likely]["#{r}"]
      input.size_high = params[:size_high]["#{r}"]
      input.weight = (params[:weight]["#{r}"].blank? ? 1 : params[:weight]["#{r}"])
      input.gross_low = params[:gross_low]["#{r}"]
      input.gross_most_likely = params[:gross_most_likely]["#{r}"]
      input.gross_high = params[:gross_high]["#{r}"]
      input.flag = params[:flag]["#{r}"]
      input.save

      @gross << input
    end

    @module_project.pemodule.attribute_modules.each do |am|
      @evs = EstimationValue.where(:module_project_id => @module_project.id, :pe_attribute_id => am.pe_attribute.id).all
      @evs.each do |ev|
        tmp_prbl = Array.new
        ["low", "most_likely", "high"].each do |level|
          if am.pe_attribute.alias == "retained_size"
            level_est_val = ev.send("string_data_#{level}")
            level_est_val[current_component.id] = @gross.map(&:"gross_#{level}").compact.sum
            tmp_prbl << level_est_val[current_component.id]
          end
          ev.update_attribute(:"string_data_#{level}", level_est_val)
        end

        if am.pe_attribute.alias == "retained_size" and ev.in_out == "output"
          ev.update_attribute(:"string_data_probable", { current_component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) } )
        end
      end
    end

    @uow_inputs = UowInput.where(module_project_id: @module_project, pbs_project_element_id: @pbs.id).all

    redirect_to main_app.dashboard_path(@project)

  end

  def load_gross

    @module_project = current_module_project
    @pbs = current_component
    @uow_inputs = UowInput.where(module_project_id: @module_project, pbs_project_element_id: @pbs.id).all

    @size = Array.new
    @tmp_result = Hash.new
    @result = Hash.new
    @level = ["gross_low", "gross_most_likely", "gross_high"]

    @size << params[:size_low]
    @size << params[:size_most_likely]
    @size << params[:size_high]

    if params['index']
      @index = params['index'].to_i - 2
    else
      @index = 1
    end

    weight = params[:"weight"].blank? ? 1 : params[:"weight"]
    technology_productivity_ratio = OrganizationTechnology.find(params[:technology]).productivity_ratio
    productivity_ratio =  technology_productivity_ratio.nil? ? 1 : technology_productivity_ratio

    abacus_value = SizeUnitTypeComplexity.where(size_unit_type_id: params["size_unit_type"], organization_uow_complexity_id: params[:complexity]).first.value

    @result[:"gross_low_#{@index.to_s}"] = params[:size_low].to_i * abacus_value.to_f * weight.to_f * productivity_ratio.to_f
    @result[:"gross_most_likely_#{@index.to_s}"] = params[:size_most_likely].to_i * abacus_value * weight.to_f * productivity_ratio.to_f
    @result[:"gross_high_#{@index.to_s}"] = params[:size_high].to_i * abacus_value * weight.to_f * productivity_ratio.to_f
  end

  def update_complexity_select_box
    @complexities = OrganizationUowComplexity.where(unit_of_work_id: params[:uow_id], organization_technology_id: params[:technology_id]).all.map{|i| [i.name, i.id]}
    @index = params[:index]
  end

  def update_unit_of_works_select_box
    @index = params[:index]
    @technology = OrganizationTechnology.find(params[:technology_id])
    @unit_of_works = @technology.unit_of_works
    @complexities = OrganizationUowComplexity.where(organization_technology_id: params[:technology_id], unit_of_work_id: @technology.unit_of_works.first).all.map{|i| [i.name, i.id]}

    @index = params[:index]
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_pemodule
    @module_project = current_module_project
    @pbs = current_component
    @uow_inputs = UowInput.where(module_project_id: @module_project, pbs_project_element_id: @pbs.id).all
    @organization_technologies = @project.organization.organization_technologies.map{|i| [i.name, i.id]}
    @unit_of_works = @project.organization.unit_of_works.map{|i| [i.name, i.id]}
    @complexities = current_component.organization_technology.organization_uow_complexities.map{|i| [i.name, i.id]}

    @module_project.pemodule.attribute_modules.each do |am|
      if am.pe_attribute.alias ==  "retained_size"
        @size = EstimationValue.where(:module_project_id => @module_project.id,
                                      :pe_attribute_id => am.pe_attribute.id,
                                      :in_out => "input" ).first

        @gross_size = EstimationValue.where(:module_project_id => @module_project.id, :pe_attribute_id => am.pe_attribute.id).first
      end
    end
  end

end