#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012-2013 Spirula (http://www.spirula.fr)
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
########################################################################

require 'cocomo_basic/version'
module CocomoBasic

  #Definition of CocomoBasic
  class CocomoBasic

    attr_accessor :coef_a, :coef_b, :coef_c, :coef_sloc, :complexity, :effort, :delay, :project

    #Constructor
    def initialize(elem)
      @coef_sloc = elem['sloc'].to_f / 1000
      @project = Project.find(elem[:current_project_id])

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

    #Setters
    def set_cocomo_organic
      @coef_a = 2.4
      @coef_b = 1.05
      @coef_c = 0.38
      @complexity = 'Organic'
    end

    def set_cocomo_semidetached
      @coef_a = 3
      @coef_b = 1.12
      @coef_c = 0.35
      @complexity = 'Semi-detached'
    end

    def set_cocomo_embedded
      @coef_a = 3.6
      @coef_b = 1.2
      @coef_c = 0.32
      @complexity = 'Embedded'
    end

    #Getters
    #Return effort (in man-month)
    def get_effort_person_month(*args)
      @effort = (@coef_a*(@coef_sloc**@coef_b)).to_f
    end

    #Return delay (in month)
    def get_delay(*args)
      @delay = (2.5*((get_effort_person_month)**@coef_c)).to_f
      @delay = @delay.to_f * @project.organization.number_hours_per_month.to_f
      @delay
    end

    #Return end date
    def get_end_date(*args)
      @end_date = (Time.now + (get_delay).to_i.hours)
    end

    #Return staffing
    def get_staffing(*args)
      @staffing = (get_effort_person_month * @project.organization.number_hours_per_month.to_f) / get_delay
      @staffing.ceil
    end

    def get_complexity(*args)
      @complexity
    end

    def get_cost(*args)
      get_effort_person_month  * @project.organization.number_hours_per_month.to_f * @project.organization.cost_per_hour.to_f
    end
  end

end
