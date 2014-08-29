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

require 'uow/version'

module Uow

  #Definition of Uo
  class Uow

    include ApplicationHelper

    attr_accessor :effort_person_month

    #Constructor
    def initialize(elem)
      @effort_person_month = elem['effort_person_month']
    end

    # Return effort
    #project.id, current_mp_to_execute.id, pbs_project_element_id)
    def get_effort_person_month(*args)
      Input.where(:module_project_id => args[1], pbs_project_element_id: args[2]).map(&:"gross_#{args[3]}").compact.sum
    end

    def get_end_date(*args)
      '-'
    end

    def get_delay(*args)
      '-'
    end

    def get_cost(*args)
      @project = Project.find(args[0])
      @effort_person_month.to_f * @project.organization.number_hours_per_month.to_f * @project.organization.cost_per_hour.to_f
    end
  end

end
