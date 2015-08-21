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
            cwu.save
          end

        end
      end
    end

    unless params[:coefficient].nil?
      params[:coefficient].each do |i|
        i.last.each do |j|
          ot = OrganizationTechnology.find(j.first.to_i)
          cplx = Guw::GuwComplexity.find(i.first.to_i)

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
      redirect_to guw.guw_model_path(@guw_type.guw_model, anchor: "tabs-#{@guw_type.name.gsub(" ", "-")}")
    end
  end
end
