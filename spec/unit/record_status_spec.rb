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
describe RecordStatus do
  before :each do
    @RecordStatus=  FactoryGirl.create(:proposed_to_save_status)
  end
  #
  it 'should return record_status name' do
    @RecordStatus.to_s().should eql( @RecordStatus.name)
  end

  #it "should be not valid" do
  #  @RecordStatus.name= 1
  #  @RecordStatus.wbs_activity_name.should_not be_instance_of(String)
  #end
  #
  #it "should be valid" do
  #  @RecordStatus.wbs_activity_name.should be_an_instance_of(String)
  #end



end