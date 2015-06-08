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

describe SearchesHelper do

  before :each do
    @sloc_attribute = FactoryGirl.create(:sloc_attribute)
  end

  it "should display link" do
    display_link(@sloc_attribute, "toto").should == "<a href=\"/pe_attributes/#{@sloc_attribute.id}/edit\" class=\"search_result\" style=\"font-size:12px; color: #467aa7;\">Sloc1 (sloc1)</a>"
  end

  it "should display description" do
    display_description(@sloc_attribute, "toto").should == "Attribute number 1"
  end

  it "should display last updated date" do
    display_update(@sloc_attribute).should ==  "#{I18n.t(:text_latest_update)} #{I18n.l(@sloc_attribute.updated_at)}"
  end

end
