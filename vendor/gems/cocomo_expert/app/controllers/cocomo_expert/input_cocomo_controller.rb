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

class CocomoExpert::InputCocomoController < ApplicationController

  def index
    set_breadcrumbs "Cocomo Expert" => ""

    @sf = []
    @em = []

    aliass = %w(pers rcpx ruse pdif prex fcil sced)
    aliass.each do |a|
      @em << Factor.where(alias: a).first
    end

    aliass = %w(prec flex resl team pmat)
    aliass.each do |a|
      @sf << Factor.where(alias: a).first
    end
  end

  def cocomo_save
    params['factors'].each do |factor|
      cmplx = OrganizationUowComplexity.find(factor[1])

      old_cocomos = InputCocomo.where(factor_id: factor[0].to_i,
                                      pbs_project_element_id: current_component.id,
                                      project_id: @project.id,
                                      module_project_id: current_module_project.id).delete_all

      InputCocomo.create(factor_id: factor[0].to_i,
                         organization_uow_complexity_id: cmplx.id,
                         pbs_project_element_id: current_component.id,
                         project_id: @project.id,
                         module_project_id: current_module_project.id,
                         coefficient: cmplx.value)

    end

    current_module_project.pemodule.attribute_modules.each do |am|
      @evs = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => am.pe_attribute.id).all
      @evs.each do |ev|
        tmp_prbl = Array.new
        ["low", "most_likely", "high"].each do |level|

          ca = CocomoExpert::CocomoExpert.new(params["size_#{level}"], params["complexity_#{level}"], @project)

          if am.pe_attribute.alias == "effort"
            ev.send("string_data_#{level}")[current_component.id] = ca.get_effort(current_component, current_module_project)
          elsif am.pe_attribute.alias == "sloc"
            ev.send("string_data_#{level}")[current_component.id] = params["size_#{level}"].to_i
          elsif am.pe_attribute.alias == "delay"
            ev.send("string_data_#{level}")[current_component.id] = ca.get_delay(current_component, current_module_project)
          elsif am.pe_attribute.alias == "cost"
            ev.send("string_data_#{level}")[current_component.id] = ca.get_cost(current_component, current_module_project)
          elsif am.pe_attribute.alias == "staffing"
            ev.send("string_data_#{level}")[current_component.id] = ca.get_staffing(current_component, current_module_project)
          elsif am.pe_attribute.alias == "end_date"
            ev.send("string_data_#{level}")[current_component.id] = ca.get_end_date(current_component, current_module_project)
          elsif am.pe_attribute.alias == "defects"
            ev.send("string_data_#{level}")[current_component.id] = ca.get_defects(current_component, current_module_project)
          end

          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]

          ev.update_attribute(:"string_data_#{level}", ev.send("string_data_#{level}"))
        end

        if ev.in_out == "output" && am.pe_attribute.alias != "end_date"
          ev.update_attribute(:"string_data_probable", { current_component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) } )
        end
      end
    end

    redirect_to main_app.dashboard_path(@project)
  end

  def help
    @factor = Factor.find(params[:factor_id])
  end

  def add_note_to_factor
    @factor = Factor.find(params[:factor_id])
    ic = InputCocomo.where( factor_id: params[:factor_id],
                            pbs_project_element_id: current_component.id,
                            project_id: @project.id,
                            module_project_id: current_module_project.id).first
    if ic.nil?
      @notes = ""
    else
      @notes = ic.notes
    end
  end

  def add_note_to_size
    ic = InputCocomo.where( factor_id: nil,
                            pbs_project_element_id: current_component.id,
                            project_id: @project.id,
                            module_project_id: current_module_project.id).first
    if ic.nil?
      @notes = ""
    else
      @notes = ic.notes
    end
  end

  def notes_form
    ic = InputCocomo.where( factor_id: params[:factor_id],
                            pbs_project_element_id: current_component.id,
                            project_id: @project.id,
                            module_project_id: current_module_project.id).first

    if ic.nil?
      InputCocomo.create( factor_id: params[:factor_id],
                          pbs_project_element_id: current_component.id,
                          project_id: @project.id,
                          module_project_id: current_module_project.id,
                          notes: params[:notes])
    else
      ic.notes = params[:notes]
      ic.save
    end

    redirect_to main_app.dashboard_path(@project)
  end

  def notes_form_size
    ic = InputCocomo.where( factor_id: nil,
                            pbs_project_element_id: current_component.id,
                            project_id: @project.id,
                            module_project_id: current_module_project.id).first

    if ic.nil?
      InputCocomo.create( factor_id: nil,
                          pbs_project_element_id: current_component.id,
                          project_id: @project.id,
                          module_project_id: current_module_project.id,
                          notes: params[:notes])
    else
      ic.notes = params[:notes]
      ic.save
    end

    redirect_to main_app.dashboard_path(@project)
  end
end
