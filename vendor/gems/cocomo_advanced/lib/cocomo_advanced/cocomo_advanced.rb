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

require 'cocomo_advanced/version'

module CocomoAdvanced

  #Definition of CocomoBasic
  class CocomoAdvanced

    include ApplicationHelper

    attr_accessor :coef_a, :coef_b, :coef_c, :coef_sloc, :complexity, :effort, :project

    #Constructor
    def initialize(sloc, cplx, project)
      @coef_sloc = sloc.to_f / 1000
      @project = project

      case cplx
        when 'Organic'
          set_cocomo_organic
        when 'Semi-detached'
          set_cocomo_semidetached
        when 'Embedded'
          set_cocomo_embedded
        else
          set_cocomo_organic
      end
    end

    def set_cocomo_organic
      @coef_a = 3.2
      @coef_b = 1.05
      @coef_c = 0.38
      @complexity = "Organic"
    end

    def set_cocomo_semidetached
      @coef_a = 3
      @coef_b = 1.12
      @coef_c = 0.32
      @complexity = "Embedded"
    end

    def set_cocomo_embedded
      @coef_a = 2.8
      @coef_b = 1.2
      @coef_c = 0.35
      @complexity = "Semi-detached"
    end

    # Return effort
    def get_effort(pbs_project_element_id, module_project_id)
      sf = Array.new
      aliases = %w(rely data cplx ruse docu time stor pvol acap aexp ltex pcap pexp pcon tool site sced)
      aliases.each do |a|
        factor = Factor.where(alias: a, factor_type: "advanced").first

        input_cocomo = InputCocomo.where(factor_id: factor.id,
                                         pbs_project_element_id: pbs_project_element_id,
                                         module_project_id: module_project_id,
                                         project_id: @project.id).first
        ic = input_cocomo.nil? ? nil.to_f : input_cocomo.coefficient
        sf << ic
      end

      return (@coef_a * @coef_sloc ** @coef_b) * sf.inject(:*)
    end

    #Return delay (in hour)
    def get_delay(pbs_project_element_id, module_project_id)
      @effort = get_effort(pbs_project_element_id, module_project_id)
      @delay = (2.5*(@effort**@coef_c)).to_f
      @delay = @delay.to_f * @project.organization.number_hours_per_month.to_f
      @delay
    end

    #Return end date
    def get_end_date(pbs_project_element_id, module_project_id)
      @end_date = (@project.start_date + ((get_delay(pbs_project_element_id, module_project_id)) / @project.organization.number_hours_per_month.to_f).to_i.months )
      @end_date
    end

    #Return staffing
    def get_staffing(pbs_project_element_id, module_project_id)
      @staffing = (get_effort(pbs_project_element_id, module_project_id) * @project.organization.number_hours_per_month.to_f / get_delay(pbs_project_element_id, module_project_id))
      @staffing
    end

    def get_complexity(pbs_project_element_id, module_project_id)
      @complexity
    end

    def get_cost(pbs_project_element_id, module_project_id)
      @cost = get_effort(pbs_project_element_id, module_project_id) * @project.organization.number_hours_per_month.to_f * @project.organization.cost_per_hour.to_f
      @cost
    end
  end

end
