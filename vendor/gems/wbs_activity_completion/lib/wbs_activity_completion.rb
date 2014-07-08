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
require 'wbs_activity_completion/version'

module WbsActivityCompletion
  # Module Class
  class WbsActivityCompletion
    attr_accessor :pbs_project_element, :inputs_effort_person_month

    # table_inputs_effort_per_hour : is table that contains values set on each wbs-activity by user (from the project estimation view)
    # module_input_data: is a Hash each activity  with its corresponding effort
    def initialize(module_input_data)
      @pbs_project_element = PbsProjectElement.find(module_input_data[:pbs_project_element_id])
      @inputs_effort_person_month = module_input_data[:effort_person_month]
    end

    # The Output result
    def get_effort_person_month(*args)
      output_effort_person_month = Hash.new
      @inputs_effort_person_month.each {|key, value| output_effort_person_month[key.to_i] = value.blank? ? nil : value.to_f}
      output_effort_person_month
    end
  end
end
