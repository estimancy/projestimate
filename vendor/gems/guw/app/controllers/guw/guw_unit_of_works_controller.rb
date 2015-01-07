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
    @guw_unit_of_work.save

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
    @guw_unit_of_work.delete
    redirect_to main_app.dashboard_path(@project)
  end

  def save_guw_unit_of_works

    hb = false
    @guw_model = current_module_project.guw_model
    @guw_unit_of_works = Guw::GuwUnitOfWork.where(module_project_id: current_module_project.id,
                                                  pbs_project_element_id: current_component.id,
                                                  guw_model_id: @guw_model.id)

    @guw_unit_of_works.each do |guw_unit_of_work|

      #guw_unit_of_work.guw_type_id = params["guw_type"]["#{guw_unit_of_work.id}"]
      #guw_unit_of_work.save

      @guw_type = guw_unit_of_work.guw_type


      @lows = Array.new
      @mls = Array.new
      @highs = Array.new
      @weight_pert = Array.new

      guw_unit_of_work.guw_unit_of_work_attributes.each do |guowa|

        low = params["low"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["low"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
        most_likely = params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
        high = params["high"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["high"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?

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
                if low.between?(@guw_attribute_complexities.map(&:bottom_range).compact.min.to_i, @guw_attribute_complexities.map(&:top_range).compact.max.to_i)
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
              if most_likely.between?(@guw_attribute_complexities.map(&:bottom_range).compact.min.to_i, @guw_attribute_complexities.map(&:top_range).compact.max.to_i)
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
              if high.between?(@guw_attribute_complexities.map(&:bottom_range).compact.min.to_i, @guw_attribute_complexities.map(&:top_range).compact.max.to_i)
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

        guw_work_unit = Guw::GuwWorkUnit.find(params[:work_unit]["#{guw_unit_of_work.id}"].to_i)

        guw_unit_of_work.result_low = @lows.sum * guw_work_unit.value.to_f
        guw_unit_of_work.result_most_likely = @mls.sum * guw_work_unit.value.to_f
        guw_unit_of_work.result_high = @highs.sum * guw_work_unit.value.to_f

        guw_unit_of_work.guw_work_unit_id = guw_work_unit.id

        guw_unit_of_work.tracking = params[:tracking]["#{guw_unit_of_work.id}"]
        guw_unit_of_work.save

        @guw_type.guw_complexities.each do |guw_c|

          #Save if uo is simple/ml/high
          value_pert = compute_probable_value(guw_unit_of_work.result_low, guw_unit_of_work.result_most_likely, guw_unit_of_work.result_high)[:value]

          if (value_pert >= guw_c.bottom_range) and (value_pert < guw_c.top_range)
            guw_unit_of_work.guw_complexity_id = guw_c.id
            guw_unit_of_work.save
          end

          #Save effective effort (or weight) of uo
          if (guw_unit_of_work.result_low >= guw_c.bottom_range) and (guw_unit_of_work.result_low < guw_c.top_range)
            uo_weight_low = guw_c.weight
          end

          if (guw_unit_of_work.result_most_likely >= guw_c.bottom_range) and (guw_unit_of_work.result_most_likely < guw_c.top_range)
            uo_weight_ml = guw_c.weight
          end

          if (guw_unit_of_work.result_high >= guw_c.bottom_range) and (guw_unit_of_work.result_high < guw_c.top_range)
            uo_weight_high = guw_c.weight
          end

          @weight_pert << compute_probable_value(uo_weight_low, uo_weight_ml, uo_weight_high)[:value]
          #@weight_pert << (uo_weight_low.to_f + 4 * uo_weight_ml.to_f + uo_weight_high.to_f)/6
        end

        guw_unit_of_work.effort = @weight_pert.sum
        guw_unit_of_work.ajusted_effort = @weight_pert.sum


        if params["ajusted_effort"]["#{guw_unit_of_work.id}"].blank?
          guw_unit_of_work.ajusted_effort = @weight_pert.sum
        elsif params["ajusted_effort"]["#{guw_unit_of_work.id}"] != @weight_pert.sum
          guw_unit_of_work.ajusted_effort = params["ajusted_effort"]["#{guw_unit_of_work.id}"]
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

          effort = Guw::GuwUnitOfWork.where(module_project_id: @module_project.id,
                                            pbs_project_element_id: current_component.id,
                                            guw_model_id: @guw_model.id).map(&:ajusted_effort).compact.sum

          if am.pe_attribute.alias == "effort"
            ev.send("string_data_#{level}")[current_component.id] = effort
            tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
          end

          guw = Guw::Guw.new(effort, params["complexity_#{level}"], @project)

          if am.pe_attribute.alias == "delay"
            ev.send("string_data_#{level}")[current_component.id] = guw.get_delay(effort, current_component, current_module_project)
            tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
          elsif am.pe_attribute.alias == "cost"
            ev.send("string_data_#{level}")[current_component.id] = guw.get_cost(effort, current_component, current_module_project)
            tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
          elsif am.pe_attribute.alias == "defects"
            ev.send("string_data_#{level}")[current_component.id] = guw.get_defects(effort, current_component, current_module_project)
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

  def create_notes

  end

end
