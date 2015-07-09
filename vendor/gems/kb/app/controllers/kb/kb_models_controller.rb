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
    authorize! :show_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:id])
    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.edit_organization_path(@kb_model.organization), @kb_model.organization => ""
  end

  def new
    authorize! :manakb_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])
    @kb_model = Kb::KbModel.new
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:id])
    @organization = @kb_model.organization

    set_breadcrumbs "Organizations" => "/organizationals_params", "Modèle d'UO" => main_app.edit_organization_path(@kb_model.organization), @kb_model.organization => ""
  end

  def import
    file = Roo::Spreadsheet.open(params[:file].path, extension: :xls)
    @kb_model = Kb::KbModel.find(params[:kb_model_id])

    ((file.first_row + 1)..file.last_row).each do |line|
      attr_one   = file.cell(line, 'A')
      attr_two   = file.cell(line, 'B')

      h = Hash.new
      h[file.cell(1, 'C').to_sym] = file.cell(line, 'C')
      h[file.cell(1, 'D').to_sym] = file.cell(line, 'D')
      h[file.cell(1, 'E').to_sym] = file.cell(line, 'E')
      h[file.cell(1, 'F').to_sym] = file.cell(line, 'F')

      Kb::KbData.create(size: attr_one,
                        effort: attr_two,
                        unit: "UF",
                        custom_attributes: h,
                        kb_model_id: @kb_model.id)
    end

    redirect_to main_app.organization_module_estimation_path(@kb_model.organization_id, anchor: "kb")
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
    @organization = @kb_model.organization

    if @kb_model.update_attributes(params[:kb_model])
      redirect_to main_app.organization_module_estimation_path(@kb_model.organization_id, anchor: "kb")
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

    conditions = Hash.new
    e_array = Array.new
    e_array2 = Array.new
    s_array = Array.new
    s_array2 = Array.new
    es_array = Array.new

    params["filters"].each{ |i, j| conditions[i.to_sym] = j }

    results = @kb_model.kb_datas.where(custom_attributes: "#{conditions.to_yaml}").all
    results.each do |kb_data|

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

    results.map do |kb_data|
      @values << [kb_data.size, kb_data.effort]
    end

    results.map(&:size).each do |i|
      @regression << [i, coef_10 * i ** pente]
    end

    @kb_model.formula = "#{coef_10} X ^ #{pente}"
    @kb_model.values = @values
    @kb_model.regression = @regression

    @kb_model.save


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
          effort = coef_10 * params[:size].to_f ** pente
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

    redirect_to main_app.dashboard_path(@project)
  end


end
