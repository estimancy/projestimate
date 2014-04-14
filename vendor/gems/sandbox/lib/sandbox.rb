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

require 'sandbox/version'

module Sandbox
  class Sandbox
    attr_accessor :description_sandbox,
                  :list_sandbox,
                  :integer_sandbox,
                  :float_sandbox,
                  :date_sandbox

    def initialize(input)
      @description_sandbox = input[:description_sandbox]
      @list_sandbox = input[:list_sandbox]

      input[:float_sandbox].blank? ?
          @float_sandbox = nil :
          @float_sandbox = input[:float_sandbox].to_f

      input[:integer_sandbox].blank? ?
          @integer_sandbox = nil :
          @integer_sandbox = input[:integer_sandbox].to_i

      @date_sandbox = input[:date_sandbox]
    end

    def get_description_sandbox(*args)
      @description_sandbox
    end

    def get_list_sandbox(*args)
      @list_sandbox
    end

    def get_integer_sandbox(*args)
      @integer_sandbox
    end

    def get_float_sandbox(*args)
      @float_sandbox
    end

    def get_date_sandbox(*args)
      @date_sandbox
    end

  end
end
