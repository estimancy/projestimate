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

describe PbsProjectElement do

  before :each do
    @work_element_type = FactoryGirl.build(:work_element_type, :wet_folder)
    @folder = FactoryGirl.create(:pbs_folder)   # Pbs_project_element
    @folder1 = FactoryGirl.create(:pbs_folder, :name => "Folder1", :work_element_type => @work_element_type)
    @bad = FactoryGirl.create(:pbs_bad, :name => "bad_name")
  end

  it 'should be valid' do
    @folder.should be_valid
  end

  it "should be not valid without name" do
    @bad.name = ""
    @bad.should_not be_valid
  end

  it "should return PBS Project element name" do
    @folder.to_s.should eql("Folder")
  end

  it "should have a correct type" do
    expect(@folder1.name).to eql("Folder1")
  end

  it "should duplicate pbs project element" do
    @folder2 = @folder.amoeba_dup
    @folder2.copy_id = @folder.id
  end

end
