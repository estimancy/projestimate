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
#############################################################################


class Guw::GuwUnitOfWorksController < ApplicationController

  include ModuleProjectsHelper

  def new
    @guw_unit_of_work = Guw::GuwUnitOfWork.new
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
  end

  def edit
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
  end

  def create
    @guw_type = Guw::GuwType.find(params[:guw_unit_of_work][:guw_type_id])
    @guw_model = Guw::GuwModel.find(params[:guw_unit_of_work][:guw_model_id])
    @guw_unit_of_work = Guw::GuwUnitOfWork.new(params[:guw_unit_of_work])

    @guw_unit_of_work.guw_model_id = @guw_model.id
    @guw_unit_of_work.module_project_id = current_module_project.id
    @guw_unit_of_work.pbs_project_element_id = current_component.id
    @guw_unit_of_work.selected = true

    if params[:position].blank?
      @guw_unit_of_work.display_order = @guw_unit_of_work.guw_unit_of_work_group.guw_unit_of_works.size.to_i + 1
    else
      @guw_unit_of_work.display_order = params[:position].to_i - 1
    end

    @guw_unit_of_work.save

    reorder @guw_unit_of_work.guw_unit_of_work_group

    @guw_model.guw_attributes.all.each do |gac|
      Guw::GuwUnitOfWorkAttribute.create(
          guw_type_id: @guw_type.id,
          guw_unit_of_work_id: @guw_unit_of_work.id,
          guw_attribute_id: gac.id)
    end

    redirect_to main_app.dashboard_path(@project)
  end

  def update
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
    @guw_unit_of_work.update_attributes(params[:guw_unit_of_work])
    redirect_to main_app.dashboard_path(@project)
  end

  def destroy
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
    group = @guw_unit_of_work.guw_unit_of_work_group
    @guw_unit_of_work.delete
    reorder group
    redirect_to main_app.dashboard_path(@project)
  end

  def up
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @guw_unit_of_work.display_order = @guw_unit_of_work.display_order - 2
    @guw_unit_of_work.save
    reorder @guw_unit_of_work.guw_unit_of_work_group
    redirect_to :back
  end

  def down
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @guw_unit_of_work.display_order = @guw_unit_of_work.display_order + 1
    @guw_unit_of_work.save
    reorder @guw_unit_of_work.guw_unit_of_work_group
    redirect_to :back
  end

  def save_guw_unit_of_works

    hb = false
    @guw_model = current_module_project.guw_model
    @guw_unit_of_works = Guw::GuwUnitOfWork.where(module_project_id: current_module_project.id,
                                                  pbs_project_element_id: current_component.id,
                                                  guw_model_id: @guw_model.id)

    @guw_unit_of_works.each_with_index do |guw_unit_of_work, i|

      reorder guw_unit_of_work.guw_unit_of_work_group

      @guw_type = guw_unit_of_work.guw_type

      @lows = Array.new
      @mls = Array.new
      @highs = Array.new
      @weight_pert = Array.new

      guw_unit_of_work.guw_unit_of_work_attributes.each do |guowa|

        #Peut être factorisé  dans une boucle !
        if @guw_model.three_points_estimation == true
          #Estimation 3 points
          if params["low"]["#{guw_unit_of_work.id}"].nil?
            low = 0
          else
            low = params["low"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["low"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
          end

          if params["most_likely"]["#{guw_unit_of_work.id}"].nil?
            most_likely = 0
          else
            most_likely = params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
          end

          if params["high"]["#{guw_unit_of_work.id}"].nil?
            high = 0
          else
            high = params["high"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["high"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
          end
        else
          #Estimation 1 point
          if params["most_likely"]["#{guw_unit_of_work.id}"].nil?
            low = most_likely = high = 0
          else
            low = most_likely = high = params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
          end
        end

        guw_unit_of_work.off_line = false

        @guw_attribute_complexities = Guw::GuwAttributeComplexity.where(guw_type_id: @guw_type.id,
                                                                        guw_attribute_id: guowa.guw_attribute_id).all

        sum_range = guowa.guw_attribute.guw_attribute_complexities.where(guw_type_id: @guw_type.id).map{|i| [i.bottom_range, i.top_range]}.flatten.compact

        if sum_range.nil? || sum_range.blank? || sum_range == 0
          # ??
        else
          @guw_attribute_complexities.each do |guw_ac|
            unless low.nil?
              unless guw_ac.bottom_range.nil? || guw_ac.top_range.nil?
                if (low >= @guw_attribute_complexities.map(&:bottom_range).compact.min.to_i) and (low < @guw_attribute_complexities.map(&:top_range).compact.max.to_i)
                  unless guw_ac.bottom_range.nil? || guw_ac.top_range.nil?
                    if (low >= guw_ac.bottom_range) and (low < guw_ac.top_range)
                      @lows << guw_ac.guw_type_complexity.value
                    end
                  end
                else
                  guw_unit_of_work.off_line = true
                end
              end
            end

            unless most_likely.nil?
              if (most_likely >= @guw_attribute_complexities.map(&:bottom_range).compact.min.to_i) and (high < @guw_attribute_complexities.map(&:top_range).compact.max.to_i)
                unless guw_ac.bottom_range.nil? || guw_ac.top_range.nil?
                  if (most_likely >= guw_ac.bottom_range) and (most_likely < guw_ac.top_range)
                    @mls << guw_ac.guw_type_complexity.value
                  end
                end
              else
                guw_unit_of_work.off_line = true
              end
            end

            unless high.nil?
              if (high >= @guw_attribute_complexities.map(&:bottom_range).compact.min.to_i) and (high < @guw_attribute_complexities.map(&:top_range).compact.max.to_i)
                unless guw_ac.bottom_range.nil? || guw_ac.top_range.nil?
                  if (high >= guw_ac.bottom_range) and (high < guw_ac.top_range)
                    @highs << guw_ac.guw_type_complexity.value
                  end
                end
              else
                guw_unit_of_work.off_line = true
              end
            end
          end
        end

        guowa.low = low
        guowa.most_likely = most_likely
        guowa.high = high
        guowa.save
      end

      guw_unit_of_work.result_low = @lows.sum
      guw_unit_of_work.result_most_likely = @mls.sum
      guw_unit_of_work.result_high = @highs.sum

      guw_unit_of_work.tracking = params[:tracking]["#{guw_unit_of_work.id}"]
      guw_unit_of_work.comments = params[:comments]["#{guw_unit_of_work.id}"]
      guw_unit_of_work.organization_technology_id = params[:guw_technology]["#{guw_unit_of_work.id}"]

      guw_unit_of_work.save

      @guw_type.guw_complexities.each do |guw_c|

        #Save if uo is simple/ml/high
        value_pert = compute_probable_value(guw_unit_of_work.result_low, guw_unit_of_work.result_most_likely, guw_unit_of_work.result_high)[:value]

        if (value_pert >= guw_c.bottom_range) and (value_pert < guw_c.top_range)
          guw_unit_of_work.guw_complexity_id = guw_c.id
          guw_unit_of_work.save
        end

        #Save effective effort (or weight) of uo
        guw_work_unit = Guw::GuwWorkUnit.find(params[:work_unit]["#{guw_unit_of_work.id}"])
        guw_unit_of_work.guw_work_unit_id = guw_work_unit.id

        if (guw_unit_of_work.result_low >= guw_c.bottom_range) and (guw_unit_of_work.result_low < guw_c.top_range)
          cwu = Guw::GuwComplexityWorkUnit.where(guw_complexity_id: guw_c.id,
                                                 guw_work_unit_id: guw_work_unit.id).first
          tcplx = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_c.id,
                                                     organization_technology_id: guw_unit_of_work.organization_technology_id).first

          uo_weight_low = cwu.value * tcplx.coefficient.to_f
        end

        if (guw_unit_of_work.result_most_likely >= guw_c.bottom_range) and (guw_unit_of_work.result_most_likely < guw_c.top_range)
          cwu = Guw::GuwComplexityWorkUnit.where(guw_complexity_id: guw_c.id,
                                                 guw_work_unit_id: guw_work_unit.id).first
          tcplx = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_c.id,
                                                     organization_technology_id: guw_unit_of_work.organization_technology_id).first

          uo_weight_ml = cwu.value * tcplx.coefficient.to_f
        end

        if (guw_unit_of_work.result_high >= guw_c.bottom_range) and (guw_unit_of_work.result_high < guw_c.top_range)
          cwu = Guw::GuwComplexityWorkUnit.where(guw_complexity_id: guw_c.id,
                                                 guw_work_unit_id: guw_work_unit.id).first
          tcplx = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_c.id,
                                                     organization_technology_id: guw_unit_of_work.organization_technology_id).first

          uo_weight_high = cwu.value * tcplx.coefficient.to_f
        end

        @weight_pert << compute_probable_value(uo_weight_low, uo_weight_ml, uo_weight_high)[:value]
      end

      guw_unit_of_work.effort = @weight_pert.sum# * guw_work_unit.value.to_f
      guw_unit_of_work.ajusted_effort = @weight_pert.sum# * guw_work_unit.value.to_f

      if params["ajusted_effort"]["#{guw_unit_of_work.id}"].blank?
        guw_unit_of_work.ajusted_effort = @weight_pert.sum#  * guw_work_unit.value.to_f
      elsif params["ajusted_effort"]["#{guw_unit_of_work.id}"] != (@weight_pert.sum)# * guw_work_unit.value.to_f)
        guw_unit_of_work.ajusted_effort = params["ajusted_effort"]["#{guw_unit_of_work.id}"]
      end

      if guw_unit_of_work.effort == guw_unit_of_work.ajusted_effort
        guw_unit_of_work.flagged = false
      else
        guw_unit_of_work.flagged = true
      end

      guw_unit_of_work.save

    end

    @module_project = current_module_project
    @module_project.guw_model_id = @guw_model.id
    @module_project.save

    @module_project.pemodule.attribute_modules.each do |am|
      @evs = EstimationValue.where(:module_project_id => @module_project.id, :pe_attribute_id => am.pe_attribute.id).all
      @evs.each do |ev|
        tmp_prbl = Array.new
        ["low", "most_likely", "high"].each do |level|

          ajusted_effort = Guw::GuwUnitOfWork.where(module_project_id: @module_project.id,
                                                    pbs_project_element_id: current_component.id,
                                                    guw_model_id: @guw_model.id,
                                                    selected: true).map(&:ajusted_effort).compact.sum

          theorical_effort = Guw::GuwUnitOfWork.where(module_project_id: @module_project.id,
                                                      pbs_project_element_id: current_component.id,
                                                      guw_model_id: @guw_model.id,
                                                      selected: true).map(&:effort).compact.sum

          number_of_unit_of_work = Guw::GuwUnitOfWorkGroup.where(pbs_project_element_id: current_component.id,
                                                                module_project_id: current_module_project.id).all.map{|i| i.guw_unit_of_works.where(selected: true)}.size

          if am.pe_attribute.alias == "effort"
            ev.send("string_data_#{level}")[current_component.id] = ajusted_effort
            tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
          elsif am.pe_attribute.alias == "theorical_effort"
            ev.send("string_data_#{level}")[current_component.id] = theorical_effort
            tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
          end

          guw = Guw::Guw.new(theorical_effort, ajusted_effort, params["complexity_#{level}"], @project)

          if am.pe_attribute.alias == "delay"
            ev.send("string_data_#{level}")[current_component.id] = guw.get_delay(ajusted_effort, current_component, current_module_project)
            tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
          elsif am.pe_attribute.alias == "cost"
            ev.send("string_data_#{level}")[current_component.id] = guw.get_cost(ajusted_effort, current_component, current_module_project)
            tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
          elsif am.pe_attribute.alias == "defects"
            ev.send("string_data_#{level}")[current_component.id] = guw.get_defects(ajusted_effort, current_component, current_module_project)
            tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
          elsif am.pe_attribute.alias == "number_of_unit_of_work"
            ev.send("string_data_#{level}")[current_component.id] = number_of_unit_of_work
            tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
          end

          ev.update_attribute(:"string_data_#{level}", ev.send("string_data_#{level}"))
        end

        if ev.in_out == "output"
          begin
            ev.update_attribute(:"string_data_probable", { current_component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) } )
          rescue
            #on ne gere pas les dates
          end
        end

      end
    end

    redirect_to main_app.dashboard_path(@project)
  end

  def change_selected_state
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    if @guw_unit_of_work.selected == false
      @guw_unit_of_work.selected = true
    else
      @guw_unit_of_work.selected = false
    end

    @guw_unit_of_work.save

    @group = Guw::GuwUnitOfWorkGroup.find(params[:guw_unit_of_work_group_id])

    #For grouped unit of work
    @group_effort_ajusted = Guw::GuwUnitOfWork.where(selected: true,
                                             guw_unit_of_work_group_id: @group.id,
                                             pbs_project_element_id: current_component.id,
                                             module_project_id: current_module_project.id,
                                             guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.ajusted_effort.to_f }.sum

    @group_effort_theorical = Guw::GuwUnitOfWork.where(selected: true,
                                             guw_unit_of_work_group_id: @group.id,
                                             pbs_project_element_id: current_component.id,
                                             module_project_id: current_module_project.id,
                                             guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.effort.to_f }.sum

    @group_number_of_unit_of_works = Guw::GuwUnitOfWork.where(selected: true,
                                               guw_unit_of_work_group_id: @group.id,
                                               pbs_project_element_id: current_component.id,
                                               module_project_id: current_module_project.id,
                                               guw_model_id: @guw_unit_of_work.guw_model.id).size

    @group_flagged_unit_of_works = Guw::GuwUnitOfWork.where(selected: true,
                                                           flagged: true,
                                                           guw_unit_of_work_group_id: @group.id,
                                                           pbs_project_element_id: current_component.id,
                                                           module_project_id: current_module_project.id,
                                                           guw_model_id: @guw_unit_of_work.guw_model.id).size


    #For all unit of work
    @ajusted_effort = Guw::GuwUnitOfWork.where(selected: true,
                                             pbs_project_element_id: current_component.id,
                                             module_project_id: current_module_project.id,
                                             guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.ajusted_effort.to_f }.sum

    @theorical_effort = Guw::GuwUnitOfWork.where(selected: true,
                                             pbs_project_element_id: current_component.id,
                                             module_project_id: current_module_project.id,
                                             guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.effort.to_f }.sum

    @number_of_unit_of_works = Guw::GuwUnitOfWork.where(selected: true,
                                                       pbs_project_element_id: current_component.id,
                                                       module_project_id: current_module_project.id,
                                                       guw_model_id: @guw_unit_of_work.guw_model.id).size

    @flagged_unit_of_works = Guw::GuwUnitOfWork.where(selected: true,
                                                      flagged: true,
                                                       pbs_project_element_id: current_component.id,
                                                       module_project_id: current_module_project.id,
                                                       guw_model_id: @guw_unit_of_work.guw_model.id).size

  end

  def create_notes
  end

  private
  def reorder(group)
    group.guw_unit_of_works.order("display_order asc").each_with_index do |u, i|
      u.display_order = i
      u.save
    end
  end

end
