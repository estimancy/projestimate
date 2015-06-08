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

require "spec_helper"

describe WorkElementType do

  before :each do
    @work_element_type = WorkElementType.new
    @custom_status = FactoryGirl.build(:custom_status)
  end

  it 'should be not valid' do
    @work_element_type.should_not be_valid
  end

  it "should not be valid without name" do
    @work_element_type.name = ""
    @work_element_type.should_not be_valid
  end

  it "should not be valid without alias" do
    @work_element_type.alias = ""
    @work_element_type.should_not be_valid
  end

  it "should not be valid without record_status" do
    @work_element_type.record_status = nil
    @work_element_type.should_not be_valid
  end

  it "should not be valid without custom_value when record_status='Custom'" do
    @work_element_type.record_status = @custom_status
    @work_element_type.should_not be_valid
  end

  it "should return work element type name" do
    @work_element_type.to_s.should eql(@work_element_type.name)
  end

end