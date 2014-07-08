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

require 'sample_model/version'

module SampleModel
  class SampleModel
    attr_accessor :k, :r, :p, :m, :e, :s, :d

    def initialize(input)
      @k = input[:sloc].blank? ? @k = nil : @k = input[:sloc].to_f
      @r = input[:real_time_constraint].blank? ? @r = nil : @r = input[:real_time_constraint].to_f
      @p = input[:platform_maturity].blank? ? @p = nil : @p = input[:platform_maturity].to_f
      @m = input[:methodology].blank? ? @m = nil : @m = input[:methodology].to_f
    end

    def get_effort_person_month(*args)
      begin
        34.96*(450/(@p+@m))*(1 - Math.exp(((-1)*@k*@k*0.01)/32))
      rescue
        nil
      end
    end

    def get_delay(*args)
      begin
        152*(@k/2.5)*(1+(@r/10))
      rescue
        nil
      end
    end

    def get_defects(*args)
      begin
        (Math.sqrt(@k))*@k*(1/@m)
      rescue
        nil
      end
    end
  end
end
