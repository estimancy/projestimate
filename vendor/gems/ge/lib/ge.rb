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

require 'ge/version'
require 'ge/engine'
module Ge
  class Ge
    def initialize(*args)
      @project = args[0]
      @mp = args[1]
    end

    def get_effort(*args)
      attr = PeAttribute.where(alias: "effort").first
      #EstimationValue.where(module_project_id: @mp.id,
      #                      pe_attribute_id: attr.id).first.string_data_probable[current_component.id]
      #
      #ev.update_attribute(:"string_data_probable", { @mp.id => 69 } )
    end

    def get_retained_size(*args)

      #attr = PeAttribute.where(alias: "retained_size").first

      #EstimationValue.where(module_project_id: @mp.id,
      #                      pe_attribute_id: attr.id).first.string_data_probable[@mp.id]
    end
  end
end
