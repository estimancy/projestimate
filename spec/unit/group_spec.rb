
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

describe Group do
  before :each do
    @group = FactoryGirl.create(:group)
    @proposed_status = FactoryGirl.build(:proposed_status)
    @custom_status = FactoryGirl.build(:custom_status)
  end

  it 'should be valid' do
    @group.should be_valid
  end

  it 'should return an array' do
    #@group.project_securities_for_select(@project.id).should be_a_kind_of(Array)
  end

  it "should not be valid without name" do
    @group.name = ""
    @group.should_not be_valid
  end

  it "should not be valid  when group name already exists" do
    group2 = @group.dup
    group2.name = @group.name
    group2.save
    group2.should_not be_valid
  end

  #it "should not be valid without custom_value when record_status='Custom'" do
  #  @group.record_status = @custom_status
  #  @group.should_not be_valid
  #end

  it "should be not valid" do
    @group.name=1
    @group.to_s.should_not be_instance_of(String)
  end

  it "should be valid" do
    @group.to_s.should be_an_instance_of(String)
  end

  it "should return group name" do
    @group.to_s.should eql(@group.name)
  end

  it "should return group project_securities for selected project_id" do
    @project = FactoryGirl.create(:project)
    @group.project_securities_for_select(@project.id).should eql(@group.project_securities.first)
  end

end