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

    attr_accessor :coef_a, :coef_b, :coef_c, :coef_kls, :complexity, :effort

    #Constructor
    def initialize(elem)
      @coef_kls = elem['ksloc'].to_f
      case elem['complexity']
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
    def get_effort_man_month(*args)
      sf = Array.new

      aliass = %w(rely data cplx ruse docu time stor pvol acap aexp ltex pcap pexp pcon tool site sced)
      aliass.each do |a|
        input_cocomo = InputCocomo.where(factor_id: Factor.where(alias: a, factor_type: "advanced").first.id,
                               pbs_project_element_id: args[2],
                               module_project_id: args[1],
                               project_id: args[0]).first
        ic = input_cocomo.nil? ? nil.to_f : input_cocomo.coefficient
        sf << ic
      end

      return (@coef_a * @coef_kls ** @coef_b) * sf.inject(:*)
    end

    #Return delay (in hour)
    def get_delay(*args)
      @effort = get_effort_man_month(args[0], args[1], args[2])
      @delay = (2.5*(@effort**@coef_c)).to_f
      @delay = @delay * 152
      @delay
    end

    #Return end date
    def get_end_date(*args)
      @end_date = (Time.now + (get_delay(args[0], args[1], args[2])).to_i.hours)
      @end_date
    end

    #Return staffing
    def get_staffing(*args)
      @staffing = ((get_effort_man_month(args[0], args[1], args[2])) / get_delay(args[0], args[1], args[2]))
      @staffing
    end

    def get_complexity(*args)
      @complexity
    end

    def get_cost(*args)
      @cost = get_effort_man_month(args[0], args[1], args[2]) * 3000
      @cost
    end
  end

end
