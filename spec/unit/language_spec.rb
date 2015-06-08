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

describe Language do

  before do
    #proposed_status = FactoryGirl.build(:record_status, :proposed)
    #@language = FactoryGirl.create(:language, record_status: proposed_status)
    @language = FactoryGirl.create(:language)
    #@language2 = FactoryGirl.create(:language)
    @custom_status = FactoryGirl.build(:custom_status)
  end

  it 'should be valid' do
    @language.should be_valid
  end

  it "should not be valid without :name" do
    @language.name = ""
    @language.should_not be_valid
  end

  it "should not be valid without :locale" do
    @language.locale = ""
    @language.should_not be_valid
  end

  it "should not be valid without uuid" do
    @language.uuid = ""
    @language.should_not be_valid
  end

  it "should not be valid without record_status" do
    @language.record_status = nil
    @language.should_not be_valid
  end

  it "should not be valid without custom_value when record_status='Custom'" do
    @language.record_status = @custom_status
    @language.should_not be_valid
  end


  it "should return :language name" do
    @language.to_s.should eql(@language.name)
  end

  #it "should duplicate language" do
  #  @language.record_status.id= @defined_status.id
  #  @language2=@language.amoeba_dup
  #  @language2.record_status.name.should eql("Proposed")
  #  @language2.reference_id = @language.id
  #  @language2.reference_uuid = @language.uuid
  #end

end
