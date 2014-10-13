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

    attr_accessor :coef_a, :coef_b, :coef_c, :coef_sloc, :complexity, :effort, :project

    #Constructor
    def initialize(elem)
      @coef_sloc = elem['sloc'].to_f / 1000
      @project = Project.find(elem[:current_project_id])
    end

    # Return effort
    def get_effort(*args)
      sf = Array.new
      em = Array.new

      aliass = %w(prec flex resl team pmat)
      aliass.each do |a|
        input_cocomo = InputCocomo.where(factor_id: Factor.where(alias: a).first.id,
                                        pbs_project_element_id: args[2],
                                        module_project_id: args[1],
                                        project_id: @project.id)
        if !input_cocomo.nil? && !input_cocomo.empty?
          sf << input_cocomo.first.coefficient
        end
      end

      aliass = %w(pers rcpx ruse pdif prex fcil sced)
      aliass.each do |a|
        input_cocomo = InputCocomo.where( factor_id: Factor.where(alias: a).first.id,
                                          pbs_project_element_id: args[2],
                                          module_project_id: args[1],
                                          project_id: @project.id)
        if !input_cocomo.nil? && !input_cocomo.empty?
          em << input_cocomo.first.coefficient
        end
      end

      b = 0.91 + 0.01 * sf.sum.to_f

      #on ne gere pas BRAK
      pm = 2.94 * em.inject(:*).to_f * 1 * (@coef_sloc)**b

      return pm
    end

    #Return delay (in month)
    def get_delay(*args)
      @effort = get_effort(args[0], args[1], args[2])

      sf = Array.new
      aliass = %w(prec flex resl team pmat)
      aliass.each do |a|
        input_cocomo = InputCocomo.where(factor_id: Factor.where(alias: a).first.id,
                                         pbs_project_element_id: args[2],
                                         module_project_id: args[1],
                                         project_id: @project.id)
        if !input_cocomo.nil? && !input_cocomo.empty?
          sf << input_cocomo.first.coefficient
        end
      end

      f = 0.28 + 0.2 * (1/100) * sf.sum.to_f
      @delay = 3.76 * (@effort ** f)
      @delay = @delay.to_f * @project.organization.number_hours_per_month.to_f
      if @delay.nan?
        @delay = nil
      end

      @delay
    end

    #Return end date
    def get_end_date(*args)
      @project = Project.find(args[0].to_i)
      @end_date = (@project.start_date + ((get_delay(args[0], args[1], args[2])) / @project.organization.number_hours_per_month.to_f).to_i.months)
      @end_date
    end

    #Return staffing
    def get_staffing(*args)
      @staffing = (get_effort(args[0], args[1], args[2]) * @project.organization.number_hours_per_month.to_f) / get_delay(args[0], args[1], args[2])
      if @staffing.nan?
        @staffing = nil
      end

      @staffing.nil? ? nil : @staffing.ceil
    end

    def get_cost(*args)
      project = Project.find(args[0].to_i)
      @cost = get_effort(args[0], args[1], args[2]) * @project.organization.number_hours_per_month.to_f * @project.organization.cost_per_hour.to_f
      if @cost.nan?
        @cost = nil
      end

      @cost
    end
  end

end
