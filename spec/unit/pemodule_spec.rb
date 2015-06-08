
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

describe Pemodule do
  before :each do
    proposed_status = FactoryGirl.build(:proposed_status)
    @pemodule = FactoryGirl.create(:pemodule, :title => 'CocomoBasic', :alias => 'cocomo_basic', :description => 'CocomoBasic basic', :uuid => '121212', :record_status => proposed_status)

    @custom_status = FactoryGirl.build(:custom_status)
  end

  it 'should be valid' do
    @pemodule.should be_valid
  end

  it 'should be display title' do
    @pemodule.to_s.should eql(@pemodule.title)
  end

  it 'should not be valid without title' do
    @pemodule.title = ''
    @pemodule.should_not be_valid
  end

  it 'should not be valid without alias' do
    @pemodule.alias = ''
    @pemodule.should_not be_valid
  end

  it 'should not be valid without description' do
    @pemodule.description = ''
    @pemodule.should_not be_valid
  end

  it "should not be valid without custom_value when record_status='Custom'" do
    @pemodule.record_status = @custom_status
    @pemodule.should_not be_valid
  end

  it 'should return module title ' do
    @pemodule.to_s.should eql(@pemodule.title)
  end

end