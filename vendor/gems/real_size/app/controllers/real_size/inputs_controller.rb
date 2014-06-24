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

class RealSize::InputsController < ApplicationController
  def index
    @size_unit_types = current_project.organization.size_unit_types
  end

  def save
    project = current_project
    organization = current_project.organization
    pbs_element = current_component
    module_project = current_module_project
    technology = current_component.organization_technology

    @size_unit_types = organization.size_unit_types

    ["low", "most_likely", "high"].each do |level|
      @size_unit_types.each do |sut|
        size_unit = SizeUnit.find(params[:size_unit]["#{sut.id}"].to_i)

        tst = TechnologySizeType.where(organization_id: organization.id,
                                      organization_technology_id: technology.id,
                                      size_unit_id: params[:size_unit]["#{sut.id}"].to_i,
                                      size_unit_type_id: sut.id).first

        result = params[:"value_#{level}"]["#{sut.id}"].to_f * tst.send("value").to_f

        rzi = RealSize::Input.where( pbs_project_element_id: pbs_element.id,
                                    module_project_id: module_project.id,
                                    size_unit_id: size_unit.id,
                                    size_unit_type_id: sut.id,
                                    project_id: project.id).first

        if rzi.nil?
          RealSize::Input.create( pbs_project_element_id: pbs_element.id,
                                  module_project_id: module_project.id,
                                  size_unit_id: size_unit.id,
                                  size_unit_type_id: sut.id,
                                  project_id: project.id,
                                  "value_#{level}".to_sym => result)
        else
          rzi.update_attributes("value_#{level}".to_sym => result)
        end
      end
    end

    module_project.pemodule.attribute_modules.each do |am|
      in_ev = EstimationValue.where(module_project_id: module_project.id,
                                    pe_attribute_id: am.pe_attribute.id).first


      ["low", "most_likely", "high"].each do |level|
        if am.pe_attribute.alias == "ksloc"

          level_est_val = in_ev.send("string_data_#{level}")

          output = RealSize::Input.where( pbs_project_element_id: pbs_element.id,
                                           module_project_id: module_project.id,
                                           size_unit_id: SizeUnit.first.id,
                                           project_id: project.id).map(&:"value_#{level}").sum

          level_est_val[current_component.id] = output

        end
        in_ev.update_attribute(:"string_data_#{level}", level_est_val)
      end
    end

    redirect_to root_url
  end
end