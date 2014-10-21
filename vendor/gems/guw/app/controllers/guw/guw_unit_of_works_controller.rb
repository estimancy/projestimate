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
  def new
    @guw_unit_of_work = Guw::GuwUnitOfWork.new
  end

  def edit
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
  end

  def create
    @guw_type = Guw::GuwType.find(params[:guw_unit_of_work][:guw_type_id])
    @guw_unit_of_work = Guw::GuwUnitOfWork.new(params[:guw_unit_of_work])
    @guw_unit_of_work.guw_model_id = Guw::GuwModel.first.id
    @guw_unit_of_work.module_project_id = current_module_project.id
    @guw_unit_of_work.pbs_project_element_id = current_component.id
    @guw_unit_of_work.save

    Guw::GuwAttribute.all.each do |gac|
      Guw::GuwUnitOfWorkAttribute.create(
          guw_type_id: @guw_type.id,
          guw_unit_of_work_id: @guw_unit_of_work.id,
          guw_attribute_id: gac.id)
    end

    redirect_to main_app.root_url
  end

  def update
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
    @guw_unit_of_work.update_attributes(params[:guw_unit_of_work])
    redirect_to main_app.root_url
  end

  def save_guw_unit_of_works

    Guw::GuwModel.first.guw_unit_of_works.each do |guw_unit_of_work|

      guw_unit_of_work.guw_type_id = params["guw_type"]["#{guw_unit_of_work.id}"]
      guw_unit_of_work.save


      @guw_type = Guw::GuwType.find(params["guw_type"]["#{guw_unit_of_work.id}"])


      @lows = Array.new
      @mls = Array.new
      @highs = Array.new
      @effort_pert = Array.new

      guw_unit_of_work.guw_unit_of_work_attributes.each do |guowa|

        low = params["low"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i
        most_likely = params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i
        high = params["high"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i

        Guw::GuwAttributeComplexity.where(guw_type_id: @guw_type.id, guw_attribute_id: guowa.guw_attribute_id).all.each do |guw_ac|
          unless guw_ac.bottom_range.nil? || guw_ac.top_range.nil?
            if low.between?(guw_ac.bottom_range, guw_ac.top_range)
              @lows << guw_ac.value
            end

            if most_likely.between?(guw_ac.bottom_range, guw_ac.top_range)
              @mls << guw_ac.value
            end

            if high.between?(guw_ac.bottom_range, guw_ac.top_range)
              @highs << guw_ac.value
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

      guw_unit_of_work.save

      @guw_type.guw_complexities.each do |guw_c|

        #Save if uo is simple/ml/high
        value_pert = (guw_unit_of_work.result_low + 4 * guw_unit_of_work.result_most_likely + guw_unit_of_work.result_high)/6
        if value_pert.between?(guw_c.bottom_range, guw_c.top_range)
          guw_unit_of_work.guw_complexity_id = guw_c.id
          guw_unit_of_work.save
        end

        #Save effective effort (or weight) of uo
        if guw_unit_of_work.result_low.between?(guw_c.bottom_range, guw_c.top_range)
          uo_weight_low = guw_c.weight
        end

        if guw_unit_of_work.result_most_likely.between?(guw_c.bottom_range, guw_c.top_range)
          uo_weight_ml = guw_c.weight
        end

        if guw_unit_of_work.result_high.between?(guw_c.bottom_range, guw_c.top_range)
          uo_weight_high = guw_c.weight
        end

        @effort_pert << (uo_weight_low.to_f + 4 * uo_weight_ml.to_f + uo_weight_high.to_f)/6
      end

      guw_unit_of_work.effort = @effort_pert.sum
      guw_unit_of_work.ajusted_effort = @effort_pert.sum

      if !params["ajusted_effort"]["#{guw_unit_of_work.id}"].blank?
        if params["ajusted_effort"]["#{guw_unit_of_work.id}"] != @effort_pert.sum
          guw_unit_of_work.ajusted_effort = params["ajusted_effort"]["#{guw_unit_of_work.id}"]
        end
      end

      guw_unit_of_work.save
    end

    current_module_project.pemodule.attribute_modules.each do |am|
      @evs = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => am.pe_attribute.id).all
      @evs.each do |ev|
        tmp_prbl = Array.new
        ["low", "most_likely", "high"].each do |level|
          if am.pe_attribute.alias == "effort"
            level_est_val = ev.send("string_data_#{level}")
            level_est_val[current_component.id] = Guw::GuwUnitOfWork.where(:module_project_id => current_module_project.id, pbs_project_element_id: current_component.id).map(&:ajusted_effort).compact.sum
            tmp_prbl << level_est_val[current_component.id]
          end
          ev.update_attribute(:"string_data_#{level}", level_est_val)
        end
        if am.pe_attribute.alias == "effort" and ev.in_out == "output"
          ev.update_attribute(:"string_data_probable", { current_component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) } )
        end
      end
    end

  end

end
