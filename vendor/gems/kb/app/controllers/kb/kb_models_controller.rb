# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero Kbneral Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero Kbneral Public License for more details.
#
#    You should have received a copy of the GNU Affero Kbneral Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################


class Kb::KbModelsController < ApplicationController

  require 'roo'

  def show
    authorize! :manage_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:id])
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.edit_organization_path(@kb_model.organization), @kb_model.organization => ""
  end

  def new
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])
    @kb_model = Kb::KbModel.new
    set_page_title I18n.t(:New_knowledge_base)
  end

  def edit
    authorize! :manage_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:id])
    @current_organization
    set_page_title I18n.t(:Edit_knowledge_base)
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.edit_organization_path(@current_organization), @current_organization => ""
  end

  def import
    authorize! :manage_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:kb_model_id])

    unless params[:file].nil?
      begin
        file = Roo::Spreadsheet.open(params[:file].path, :extension => :xls)
      rescue
        flash[:error] = "Une erreur est survenue durant l'import du modèle. Veuillez vérifier l'extension du fichier Excel (.xls)"
        redirect_to kb.edit_kb_model_path(@kb_model) and return
      end

      Kb::KbData.delete_all("kb_model_id = #{@kb_model.id}")

      ((file.first_row + 1)..file.last_row).each do |line|
        attr_one   = file.cell(line, 'A')
        attr_two   = file.cell(line, 'B')

        h = Hash.new
        ('C'..'ZZ').each_with_index do |letter, i|
          if i < file.last_column
            begin
              h[file.cell(1, letter.to_s).to_sym] = file.cell(line, letter.to_s)
            rescue
            end
          end
        end

        Kb::KbData.create(size: attr_one,
                          effort: attr_two,
                          unit: "UF",
                          custom_attributes: h,
                          kb_model_id: @kb_model.id)
      end
    end

    redirect_to kb.edit_kb_model_path(@kb_model)
  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:kb_model][:organization_id])

    @kb_model = Kb::KbModel.new(params[:kb_model])
    @kb_model.organization_id = params[:kb_model][:organization_id].to_i
    if @kb_model.save
      redirect_to main_app.organization_module_estimation_path(@kb_model.organization_id, anchor: "kb")
    else
      render action: :new
    end

  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:id])

    if @kb_model.update_attributes(params[:kb_model])
      redirect_to main_app.organization_module_estimation_path(@current_organization, anchor: "kb")
    else
      render action: :edit
    end
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:id])
    organization_id = @kb_model.organization_id

    @kb_model.module_projects.each do |mp|
      mp.destroy
    end

    @kb_model.delete
    redirect_to main_app.organization_module_estimation_path(@kb_model.organization_id, anchor: "effort")
  end

  def save_efforts
    authorize! :execute_estimation_plan, @project

    @kb_model = Kb::KbModel.find(params[:kb_model_id])
    @kb_input = @kb_model.kb_inputs.where(module_project_id: current_module_project.id).first_or_create

    @project_list = Array.new
    e_array = Array.new
    e_array2 = Array.new
    s_array = Array.new
    s_array2 = Array.new
    es_array = Array.new

    @filters = params["filters"]
    @kb_input.filters = params["filters"]

    @kb_model.kb_datas.each do |i|
      unless params["filters"].nil?
        params["filters"].each do |f|
          if (params["filters"].values.include?(i.custom_attributes[f.first.to_sym]))
            @project_list << i
          end
        end
      end
    end

    # if @project_list.blank?
    #   @project_list = @kb_model.kb_datas
    # end

    @project_list.each do |kb_data|
      s = Math.log10(kb_data.size.to_f)
      s2 = s * s

      e = Math.log10(kb_data.effort.to_f)
      e2 = e * e

      se = s * e

      s_array << s
      s_array2 << s2

      e_array << e
      e_array2 << e2

      es_array << se
    end

    unless @project_list.empty?
      ms = s_array.sum / s_array.size
      ms2 = s_array2.sum / s_array2.size

      me = e_array.sum / e_array.size
      me2 = e_array2.sum / e_array2.size

      mes = es_array.sum / es_array.size

      pente = ((mes - ms * me) / (ms2 - ms * ms)).round(2)
      coef = (me - pente * ms).round(2)
      coef_10 = (10**coef).round(2)

      @values = Array.new
      @regression = Array.new
    end

    @project_list.map do |kb_data|
      @values << [kb_data.size.round(2), kb_data.effort.round(2)]
    end

    @project_list.map(&:size).each do |i|
      @regression << [i, (coef_10 * i ** pente).round(2)]
    end

    @formula = "#{coef_10.to_f} X ^ #{pente.to_f}"
    @kb_input.values = @values
    @kb_input.regression = @regression
    @kb_input.formula = @formula

    @kb_model.save
    @kb_input.save

    current_module_project.pemodule.attribute_modules.each do |am|
      tmp_prbl = Array.new

      ev = EstimationValue.where(:module_project_id => current_module_project.id,
                                 :pe_attribute_id => am.pe_attribute.id).first
      ["low", "most_likely", "high"].each do |level|

        if @kb_model.three_points_estimation?
          size = params[:"retained_size_#{level}"].to_f
        else
          size = params[:"retained_size_most_likely"].to_f
        end

        if am.pe_attribute.alias == "effort"
          effort = (coef_10.to_f * params[:size].to_f ** pente.to_f) * @kb_model.standard_unit_coefficient.to_i
          ev.send("string_data_#{level}")[current_component.id] = effort
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
        elsif am.pe_attribute.alias == "retained_size"
          ev = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => am.pe_attribute.id).first
          ev.send("string_data_#{level}")[current_component.id] = params[:size].to_f
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
        end
      end

      unless @kb_model.three_points_estimation?
        tmp_prbl[0] = tmp_prbl[1]
        tmp_prbl[2] = tmp_prbl[1]
      end

      ev.update_attribute(:"string_data_probable", { current_component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) } )
    end

    current_module_project.nexts.each do |n|
      ModuleProject::common_attributes(current_module_project, n).each do |ca|
        ["low", "most_likely", "high"].each do |level|
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_#{level}", { current_component.id => nil } )
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_probable", { current_component.id => nil } )
        end
      end
    end

    current_module_project.views_widgets.each do |vw|
      ViewsWidget::update_field(vw, @current_organization, current_module_project.project, current_component)
    end

    size_attr = PeAttribute.find_by_alias("retained_size")
    size_previous_ev = EstimationValue.where(:pe_attribute_id => size_attr.id,
                                             :module_project_id => current_module_project.previous.first.id,
                                             :in_out => "output").first
    size_current_ev = EstimationValue.where(:pe_attribute_id => size_attr.id,
                                            :module_project_id => current_module_project.id,
                                            :in_out => "input").first
    effort_attr = PeAttribute.find_by_alias("effort")
    effort_current_ev = EstimationValue.where(:pe_attribute_id => effort_attr.id,
                                              :module_project_id => current_module_project.id,
                                              :in_out => "output").first

    @size = Kb::KbModel::display_size(size_previous_ev, size_current_ev, "most_likely", current_component.id)
    eff = effort_current_ev.send("string_data_probable")[current_component.id].to_f
    @effort = eff.to_f / @kb_model.standard_unit_coefficient.to_i

  end

end
