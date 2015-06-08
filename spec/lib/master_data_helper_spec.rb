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

describe MasterDataHelper do

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

    @language = FactoryGirl.create(:en_language)
  end

  specify "records should be valid" do
    @language.should be_valid
  end

  specify "Record should have proposed status on :create" do
    @language.record_status.name.should eql(@proposed_status.name)
  end

  specify "Record should be proposed" do
    @language.record_status = @proposed_status
    expect(@language.is_proposed?).to be_truthy
  end

  specify "should be defined" do
    @language.record_status = @defined_status
    expect(@language.is_defined?).to be_truthy
  end

  it "should be inReview" do
    @language.record_status = @in_review_status
    expect(@language.is_inReview?).to be_truthy
  end

  it "should be drafted" do
    @language.record_status = @draft_status
    expect(@language.is_draft?).to be_truthy
  end

  it "should be retired" do
    @language.record_status = @retired_status
    expect(@language.is_retired?).to be_truthy
  end

  it "should be defined or nil" do
    @language.record_status = @defined_status
    expect(@language.is_defined_or_nil?).to be_truthy
  end

  it "should show custom value if record status is custom" do
    @language.record_status = @custom_status
    @language.custom_value = "Test"
    expect(@language.show_custom_value).to eql(" (Test) ")
  end

end