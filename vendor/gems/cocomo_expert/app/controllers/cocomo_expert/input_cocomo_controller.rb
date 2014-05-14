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
                                     project_id: current_project.id,
                                     module_project_id: current_module_project.id)
      old_cocomos.delete_all

      InputCocomo.create(factor_id: factor[0].to_i,
                         organization_uow_complexity_id: cmplx.id,
                         pbs_project_element_id: current_component.id,
                         project_id: current_project.id,
                         module_project_id: current_module_project.id,
                         coefficient: cmplx.value)

    end
    redirect_to main_app.root_url
  end
end
