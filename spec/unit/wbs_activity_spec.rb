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

describe WbsActivity do

  before :each do
    @wbs_activity = FactoryGirl.create(:wbs_activity)
  end

  it "should be valid" do
    @wbs_activity.should be_valid
  end

  it "should not be valid without name" do
    @wbs_activity.name = ""
    @wbs_activity.should_not be_valid
  end

  describe "Duplicate wbs activity" do
    before do
      @wbs_activity_2 = @wbs_activity.amoeba_dup
      @wbs_activity_2.save
      @wbs_activity.save
    end

    it "should return copy name" do
      @wbs_activity_2.name.should eql("#{@wbs_activity.name}")
    end

    it "Should return copy number = 0" do
      @wbs_activity_2.copy_number.should eql(0)
    end

    it "Should update the copy number" do
      @wbs_activity.copy_number.should eql(@wbs_activity.copy_number.to_i)
    end
  end
end
