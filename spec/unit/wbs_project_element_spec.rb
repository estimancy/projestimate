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

describe WbsProjectElement do
  before :each do
    @project = FactoryGirl.create(:project)
    #@wbs_activity = FactoryGirl.create(:wbs_activity)
    @pe_wbs_project = FactoryGirl.create(:pe_wbs_project, :wbs_type => "Activity", :project => @project)
    @wbs_project_element = FactoryGirl.create(:wbs_project_element, :is_root => true, :pe_wbs_project => @pe_wbs_project)
    @wbs_project_element_no_root = FactoryGirl.create(:wbs_project_element, :is_root => false, :pe_wbs_project => @pe_wbs_project)
    #@wbs_project_element_with_activity = FactoryGirl.create(:wbs_project_element, :is_root => false, :pe_wbs_project => @pe_wbs_project, :wbs_activity => @wbs_activity)
  end

  it "should be valid" do
    @wbs_project_element.should be_valid
  end

  it "should not be valid without name" do
    @wbs_project_element.name = ""
    @wbs_project_element.should_not be_valid
  end

  #it "should not be from Library" do
  #  expect(@wbs_project_element.is_from_library_and_is_leaf?).to be_falsey
  #end

  it "Duplicate project element" do
    @wbs_project_element2 = @wbs_project_element.amoeba_dup
  end

  it "should be an array" do
    #WbsProjectElement.arrange_as_array.class.should be_kind_of(Array)
    WbsProjectElement.arrange_as_array.class.should be_nil?
  end

  it "should be a boolean" do
    @wbs_project_element.can_get_new_child = true
    @wbs_project_element.update_can_get_new_child
    #@wbs_project_element.can_get_new_child.should be_false
  end

  it "should be a boolean" do
    @wbs_project_element_no_root.can_get_new_child = false
    #@wbs_project_element_no_root.update_can_get_new_child
    #@wbs_project_element_no_root.can_get_new_child.should be_false
  end

  it "should be a boolean" do
    #@wbs_project_element_no_root.destroy_leaf.should be_false
    #@wbs_project_element_with_activity.destroy_leaf.should be_true
  end

  it "should be a boolean" do
    #@wbs_project_element.get_all_complement_children.should be_kind_of(Array)
  end

  it "should be a boolean" do
    #@wbs_project_element_no_root.cannot_get_new_child_link?.should be_true
  end

  #describe "is_from_library_and_is_leaf?" do
  #  before :each do
  #    FactoryGirl.reload
  #    #@project = FactoryGirl.create(:project)
  #    @wbs_activity = FactoryGirl.create(:wbs_activity)
  #    @wbs_activity_element=FactoryGirl.create(:wbs_activity_element)
  #    @pe_wbs_project = FactoryGirl.create(:pe_wbs_project, :wbs_type => "Activity", :project => @project)
  #    @wbs_project_element2 = FactoryGirl.create(:wbs_project_element, :is_root => false, :pe_wbs_project => @pe_wbs_project,:wbs_activity => @wbs_activity, :wbs_activity_element => @wbs_activity_element)
  #    @wbs_project_element3 = FactoryGirl.create(:wbs_project_element, :is_root => false, :pe_wbs_project => @pe_wbs_project,:wbs_activity => @wbs_activity, :wbs_activity_element => @wbs_activity_element)
  #  end
  #
  #  it "should return false if  wbs_activity is nil && wbs_activity_element is nil && parent.can_get_new_child is nil" do
  #    #@wbs_project_element3 = FactoryGirl.create(:wbs_project_element, :is_root => false, :pe_wbs_project => @pe_wbs_project,:wbs_activity => nil, :wbs_activity_element => nil)
  #    #@wbs_project_element3.parent= @wbs_project_element
  #    #@wbs_project_element3.parent.can_get_new_child=nil
  #    #expect(@wbs_project_element3.is_from_library_and_is_leaf?).to be_falsey
  #  end
  #
  #  it "should return true if has children" do
  #    @wbs_project_element3 = FactoryGirl.create(:wbs_project_element, :is_root => false, :pe_wbs_project => @pe_wbs_project, :wbs_activity => @wbs_activity, :wbs_activity_element => @wbs_activity_element)
  #    @wbs_project_element.parent= @wbs_project_element3
  #    @wbs_project_element.save
  #    expect(@wbs_project_element3.is_from_library_and_is_leaf?).to be_truthy
  #  end
  #
  #  it "should return true if not has a children and can have a children" do
  #    @wbs_project_element3 = FactoryGirl.create(:wbs_project_element, :is_root => false, :pe_wbs_project => @pe_wbs_project, :wbs_activity => @wbs_activity, :wbs_activity_element => @wbs_activity_element)
  #    @wbs_project_element3.parent= @wbs_project_element
  #    @wbs_project_element.can_get_new_child=true
  #    @wbs_project_element3.save
  #    @wbs_project_element.save
  #    expect(@wbs_project_element3.is_from_library_and_is_leaf?).to be_truthy
  #  end
  #
  #  it "should return false if not has a children and can't have a children" do
  #    @wbs_project_element3 = FactoryGirl.create(:wbs_project_element, :is_root => false, :pe_wbs_project => @pe_wbs_project,:wbs_activity => @wbs_activity, :wbs_activity_element => @wbs_activity_element)
  #    @wbs_project_element3.parent = @wbs_project_element
  #    expect(@wbs_project_element3.is_from_library_and_is_leaf?).to be_falsey
  #  end
  #end

end
