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

describe ProjectCategory do
  before :each do
    @project_category = FactoryGirl.create(:ProjectCategory)
    @custom_status = FactoryGirl.build(:custom_status)
  end

  it "should be valid" do
    @project_category.should be_valid
  end

  it "should not be valid without record_status" do
    @project_category.record_status = nil
    @project_category.should_not be_valid
  end

  it "should not be valid without custom_value when record_status='Custom'" do
    @project_category.record_status = @custom_status
    @project_category.should_not be_valid
  end

  it "should be a string" do
    @project_category.name=1
    @project_category.to_s.should_not be_instance_of(String)
  end

  it "should not be a string" do
    @project_category.to_s.should be_an_instance_of(String)
  end

  it "should return project Category name" do
    @project_category.to_s.should eql(@project_category.name)
  end

end



