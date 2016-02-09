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


class Guw::GuwComplexityWorkUnitsController < ApplicationController

  def save_complexity_work_units
    unless params[:value].nil?
      params[:value].each do |i|
        i.last.each do |j|
          wu = Guw::GuwWorkUnit.find(j.first.to_i)
          cplx = Guw::GuwComplexity.find(i.first.to_i)
          @guw_type = cplx.guw_type

          cwu = Guw::GuwComplexityWorkUnit.where(guw_complexity_id: cplx.id, guw_work_unit_id: wu.id).first
          if cwu.nil?
            Guw::GuwComplexityWorkUnit.create(guw_complexity_id: cplx.id, guw_work_unit_id: wu.id, value: params[:value]["#{cplx.id}"]["#{wu.id}"])
          else
            cwu.value = params[:value]["#{cplx.id}"]["#{wu.id}"]
            cwu.guw_type_id = @guw_type.id
            cwu.save
          end

        end
      end
    end

    unless params[:weightings_value].nil?
      params[:weightings_value].each do |i|
        i.last.each do |j|
          we = Guw::GuwWeighting.find(j.first.to_i)
          cplx = Guw::GuwComplexity.find(i.first.to_i)
          @guw_type = cplx.guw_type

          cwe = Guw::GuwComplexityWeighting.where(guw_complexity_id: cplx.id, guw_weighting_id: we.id).first
          if cwe.nil?
            Guw::GuwComplexityWeighting.create(guw_complexity_id: cplx.id, guw_weighting_id: we.id, value: params[:weightings_value]["#{cplx.id}"]["#{we.id}"])
          else
            cwe.value = params[:weightings_value]["#{cplx.id}"]["#{we.id}"]
            cwe.guw_type_id = @guw_type.id
            cwe.save
          end

        end
      end
    end

    unless params[:factors_value].nil?
      params[:factors_value].each do |i|
        i.last.each do |j|
          fa = Guw::GuwFactor.find(j.first.to_i)
          cplx = Guw::GuwComplexity.find(i.first.to_i)
          @guw_type = cplx.guw_type

          cfa = Guw::GuwComplexityFactor.where(guw_complexity_id: cplx.id, guw_factor_id: fa.id).first
          if cfa.nil?
            Guw::GuwComplexityFactor.create(guw_complexity_id: cplx.id, guw_factor_id: fa.id, value: params[:factors_value]["#{cplx.id}"]["#{fa.id}"])
          else
            cfa.value = params[:factors_value]["#{cplx.id}"]["#{fa.id}"]
            cfa.guw_type_id = @guw_type.id
            cfa.save
          end

        end
      end
    end

    unless params[:coefficient].nil?
      params[:coefficient].each do |i|
        i.last.each do |j|
          ot = OrganizationTechnology.find(j.first.to_i)
          cplx = Guw::GuwComplexity.find(i.first.to_i)
          @guw_type = cplx.guw_type

          if params['enable_value'].present?
            cplx.enable_value = params['enable_value']["#{cplx.guw_type.id}"]["#{cplx.id}"].nil? ? false : true
          else
            cplx.enable_value = false
          end
          cplx.save

          ct = Guw::GuwComplexityTechnology.where(guw_complexity_id: cplx.id, organization_technology_id: ot.id).first_or_create
          ct.coefficient = params[:coefficient]["#{cplx.id}"]["#{ot.id}"]
          ct.guw_type_id = @guw_type.id
          ct.save

        end
      end
    end

    if @guw_type.nil?
      redirect_to :back
    else
      @guw_model = @guw_type.guw_model
      if @guw_model.default_display == "list"
        redirect_to guw.guw_type_path(@guw_type)
      else
        redirect_to guw.guw_model_path(@guw_model, anchor: "tabs-#{@guw_type.name.gsub(" ", "-")}")
      end
    end
  end
end
