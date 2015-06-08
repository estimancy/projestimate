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

describe PeWbsProject do

  before :each do
    @project = FactoryGirl.create(:project)
    @pe_wbs_project = FactoryGirl.create(:pe_wbs_project, :project=> @project)
  end

  it "should duplicate pe_wbs_project" do
    @pe_wbs_project2=@pe_wbs_project.amoeba_dup
    @pe_wbs_project2.name = "PE-WBS Copy_#{ @pe_wbs_project2.project.copy_number.to_i+1} of #{@pe_wbs_project2.project.title }"
  end
end
