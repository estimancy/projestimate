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

describe ProjectSecurity do

  before :each do
    @user = FactoryGirl.create(:user)
    @project = FactoryGirl.create(:project)
    @project_security_level = FactoryGirl.create(:readOnly_project_security_level)

    #@project_security = FactoryGirl.create(:project_security)
    #@project_security.project_security_level_id= @project_security_level.id
    #@project_security = ProjectSecurity.create(:user => @user, :project => @project, :project_security_level => @project_security_level)
    @project_security = @project.project_securities.build
    @project_security.user = @user
    @project_security.project_security_level = @project_security_level
    @project_security.save
   end

  it "should return '-' if level is nil" do
    @project_security.project_security_level_id = nil
    @project_security.level.should eql('-')
  end

  it "should return level name if level is not nil" do
    @project_security.level.should eql(@project_security_level.name)
  end

  it "should return id" do
    @project_security.to_s.should eql(@project_security.id.to_s)
  end
end