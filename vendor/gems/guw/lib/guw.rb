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
    attr_accessor :retained_size, :project, :delay, :defects, :cost

    def initialize(theorical_size, retained_size, cplx, project)
      @theorical_size = theorical_size
      @retained_size = retained_size
      @cplx = cplx
      @project = project
    end

    def get_defects(size, pbs_project_element_id, module_project_id)
      @defects = size*0.08*100
    end

    def get_delay(size, pbs_project_element_id, module_project_id)
      @delay = (2.5 * (size**0.32 )).to_f * @project.organization.number_hours_per_month.to_f
    end

    def get_cost(size, pbs_project_element_id, module_project_id)
      @cost = size * @project.organization.number_hours_per_month.to_f * @project.organization.cost_per_hour.to_f
    end
  end
end
