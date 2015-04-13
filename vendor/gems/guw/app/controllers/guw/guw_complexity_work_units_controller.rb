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


class Guw::GuwComplexityWorkUnitsController < ApplicationController

  def save_complexity_work_units
    unless params[:value].nil?
      params[:value].each do |i|
        i.last.each do |j|
          wu = Guw::GuwWorkUnit.find(j.first.to_i)
          cplx = Guw::GuwComplexity.find(i.first.to_i)
          @guw_type = cplx.guw_type

          cwu = Guw::GuwComplexityWorkUnit.where(guw_complexity_id: cplx.id,
                                                 guw_work_unit_id: wu.id).first

          if cwu.nil?
            Guw::GuwComplexityWorkUnit.create(guw_complexity_id: cplx.id, guw_work_unit_id: wu.id, value: params[:value]["#{cplx.id}"]["#{wu.id}"])
          else
            cwu.value = params[:value]["#{cplx.id}"]["#{wu.id}"]
            cwu.save
          end
        end
      end
    end

    params[:coefficient].each do |i|
      i.last.each do |j|
        ot = OrganizationTechnology.find(j.first.to_i)
        cplx = Guw::GuwComplexity.find(i.first.to_i)

        cwu = Guw::GuwComplexityTechnology.where(guw_complexity_id: cplx.id,
                                           organization_technology_id: ot.id).first

        if cwu.nil?
          Guw::GuwComplexityTechnology.create(guw_complexity_id: cplx.id, organization_technology_id: ot.id, coefficient: params[:coefficient]["#{cplx.id}"]["#{ot.id}"])
        else
          cwu.coefficient = params[:coefficient]["#{cplx.id}"]["#{ot.id}"]
          cwu.save
        end
      end
    end

    redirect_to guw.guw_model_path(@guw_type.guw_model, anchor: "tabs-#{@guw_type.name.gsub(" ", "-")}")
  end
end
