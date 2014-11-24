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

require 'guw/version'
require 'guw/engine'
module Guw
  class Guw
    attr_accessor :effort, :project, :delay, :defects, :cost

    def initialize(effort, cplx, project)
      @effort = effort
      @project = project
    end

    def get_effort(pbs_project_element_id, module_project_id)
      Guw::GuwUnitOfWork.where(:module_project_id => args[1], pbs_project_element_id: args[2]).map(:effort).compact.sum
    end

    def get_defects(effort, pbs_project_element_id, module_project_id)
      @defects = effort*0.08
    end

    def get_delay(effort, pbs_project_element_id, module_project_id)
      @delay = (2.5 * (effort**0.32 )).to_f
    end

    def get_cost(effort, pbs_project_element_id, module_project_id)
      @cost = effort * @project.organization.number_hours_per_month.to_f * @project.organization.cost_per_hour.to_f
    end
  end
end
