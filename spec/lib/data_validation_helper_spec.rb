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

#require "spec_helper"
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DataValidationHelper do

  before :each do
    proposed_status = FactoryGirl.build(:proposed_status, :record_status => nil)
    defined_status = FactoryGirl.build(:defined_status, :record_status => nil)
    in_review_status = FactoryGirl.build(:inReview_status, :record_status => nil)
    draft_status = FactoryGirl.build(:draft_status, :record_status => nil)
    retired_status = FactoryGirl.build(:retired_status, :record_status => nil)
    custom_status = FactoryGirl.build(:custom_status, :record_status => nil)

    @proposed_status = FactoryGirl.build(:proposed_status, :record_status => proposed_status)
    @defined_status = FactoryGirl.build(:defined_status, :record_status => proposed_status)
    @in_review_status = FactoryGirl.build(:inReview_status, :record_status => proposed_status)
    @draft_status = FactoryGirl.build(:draft_status, :record_status => proposed_status)
    @retired_status = FactoryGirl.build(:retired_status, :record_status => proposed_status)
    @custom_status = FactoryGirl.build(:custom_status, :record_status => proposed_status)

    @language = FactoryGirl.build(:language)
  end

  specify "Record should be valid " do
    @language.should be_valid
  end

  describe "Validate changes on Master data" do
    specify "record status should change" do

    end
  end
end