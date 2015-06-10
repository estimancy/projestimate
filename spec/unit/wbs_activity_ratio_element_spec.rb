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

require 'spec_helper'

describe WbsActivityRatioElement do

  before :each do
    @wbs_activity = FactoryGirl.create(:wbs_activity)
    @wbs_activity_ratio = FactoryGirl.create(:wbs_activity_ratio, :wbs_activity => @wbs_activity)
    @wbs_activity_ratio_element = FactoryGirl.create(:wbs_activity_ratio_element, :wbs_activity_ratio => @wbs_activity_ratio)
  end

  it 'should be valid' do
    @wbs_activity_ratio_element.should be_valid
  end

end
