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

describe ProjectSecurityLevel do
  before :each do
    @project_security_level = FactoryGirl.create(:readOnly_project_security_level)
    @custom_status = FactoryGirl.build(:custom_status)
  end

  it "should be valid" do
    @project_security_level.should be_valid
  end

  it "should not be valid without custom_value when record_status='Custom'" do
    @project_security_level.record_status = @custom_status
    @project_security_level.should_not be_valid
  end

end