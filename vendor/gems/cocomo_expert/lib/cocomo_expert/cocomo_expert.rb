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

require 'cocomo_expert/version'

module CocomoExpert

  #Definition of CocomoBasic
  class CocomoExpert

    attr_accessor :coef_a, :coef_b, :coef_c, :coef_kls, :complexity, :effort

    #Constructor
    def initialize(elem)
      @coef_kls = elem['ksloc'].to_f
    end

    # Return effort
    def get_effort_man_month(*args)
      sf = Array.new
      em = Array.new

      aliass = %w(prec flex resl team pmat)
      aliass.each do |a|
        ic = InputCocomo.where(factor_id: Factor.where(alias: a).first.id,
                               pbs_project_element_id: args[2],
                               module_project_id: args[1],
                               project_id: args[0]).first.coefficient
        sf << ic
      end

      aliass = %w(pers rcpx ruse pdif prex fcil sced)
      aliass.each do |a|
        em << InputCocomo.where( factor_id: Factor.where(alias: a).first.id,
                                 pbs_project_element_id: args[2],
                                 module_project_id: args[1],
                                 project_id: args[0]).first.coefficient
      end

      b = 0.91 + 0.01 * sf.sum

      #on ne gere pas BRAK
      pm = 2.94 * em.inject(:*) * 1 * (@coef_kls)**b

      return pm
    end

    #Return delay (in month)
    def get_delay(*args)
      @effort = get_effort_man_month(args[0], args[1], args[2])

      sf = Array.new
      aliass = %w(prec flex resl team pmat)
      aliass.each do |a|
        ic = InputCocomo.where(factor_id: Factor.where(alias: a).first.id,
                               pbs_project_element_id: args[2],
                               module_project_id: args[1],
                               project_id: args[0]).first.coefficient
        sf << ic
      end

      f = 0.28 + 0.2 * (1/100) * sf.sum
      @delay = 3.76 * (@effort ** f)
      @delay = @delay * 152
      @delay
    end

    #Return end date
    def get_end_date(*args)
      p = Project.find(args[0].to_i)
      @end_date = (p.start_date + (get_delay(args[0], args[1], args[2])).to_i.hours)
      @end_date
    end

    #Return staffing
    def get_staffing(*args)
      @staffing = (get_effort_man_month(args[0], args[1], args[2])*152 / get_delay(args[0], args[1], args[2]))
      @staffing
    end

    def get_cost(*args)
      @cost = get_effort_man_month(args[0], args[1], args[2]) * 3000
      @cost
    end
  end

end
