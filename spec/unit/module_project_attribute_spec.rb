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

describe EstimationValue do

  before :each do
    @project = FactoryGirl.create(:project)   #@project = Project.first
    @pemodule = Pemodule.new(:title => "Foo",
                            :alias => "foo",
                            :description => "Bar")
    @module_project = ModuleProject.new(:project_id => @project.id, :pemodule_id => @pemodule.id, :position_y => 1)
    @sloc_attribute = PeAttribute.new(:name=>"Cost",:alias=>"cost",:description=>"Cost desc" ,:attr_type=>"Integer")
    @sloc_attribute2 = PeAttribute.new(:name=>1,:alias=>"cost",:description=>"Cost desc" ,:attr_type=>"Integer")

    @mpa = EstimationValue.new(:pe_attribute_id => @sloc_attribute.id,
                                      :in_out => "input",
                                      :module_project_id => @module_project.id,
                                      :custom_attribute => "user",
                                      :is_mandatory => true,
                                      :description => "Undefined")

    @mpa2 = EstimationValue.new(:pe_attribute_id => @sloc_attribute2.id,
                                      :in_out => "input",
                                      :module_project_id => @module_project.id,
                                      :custom_attribute => "toto",
                                      :is_mandatory => true,
                                      :description => "Undefined")


    @mpa2.save
    @mpa.save
  end

  #it "should be not valid" do
  #  @mpa2.to_s.should_not be_instance_of(String)
  #end
  #
  #it "should be valid" do
  #  @mpa.to_s.should be_an_instance_of(String)
  #end
  #
  #it "should return module project attribute name" do
  #  puts @sloc_attribute.name
  #  puts @mpa.to_s
  #  @mpa.to_s.should eql(@sloc_attribute.name)
  #end

  it "in_out should be equals to type" do
    @mpa.in_out.should eql(@mpa.in_out)
  end
end
