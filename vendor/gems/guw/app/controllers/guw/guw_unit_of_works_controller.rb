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

      @guw_type = Guw::GuwType.find(params["guw_type"]["#{guw_unit_of_work.id}"])

      @lows = Array.new
      @mls = Array.new
      @highs = Array.new

      guw_unit_of_work.guw_unit_of_work_attributes.each do |guowa|

        low = params["low"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i
        most_likely = params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i
        high = params["high"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i

        @guw_type.guw_attribute_complexities.each do |guw_ac|
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

        guowa.low = low
        guowa.most_likely = low
        guowa.high = low
        guowa.save
      end

      guw_unit_of_work.result_low = @lows.sum
      guw_unit_of_work.result_most_likely = @mls.sum
      guw_unit_of_work.result_high = @highs.sum

      guw_unit_of_work.effort = params["effort"]["#{guw_unit_of_work.id}"]
      guw_unit_of_work.ajusted_effort = params["ajusted_effort"]["#{guw_unit_of_work.id}"]

      guw_unit_of_work.save

      @guw_type.guw_complexities.each do |guw_c|
        if guw_unit_of_work.result_low.between?(guw_c.bottom_range, guw_c.top_range)
          guw_unit_of_work.guw_complexity_id = guw_c.id
        end

        if guw_unit_of_work.result_most_likely.between?(guw_c.bottom_range, guw_c.top_range)
          guw_unit_of_work.guw_complexity_id = guw_c.id
        end

        if guw_unit_of_work.result_high.between?(guw_c.bottom_range, guw_c.top_range)
          guw_unit_of_work.guw_complexity_id = guw_c.id
        end
      end

      guw_unit_of_work.save

    end

  end

end
