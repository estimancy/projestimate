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

describe EstimationValue do

  before :each do
    defined_status = FactoryGirl.build(:defined_status)

    @project = FactoryGirl.create(:project, :title => 'Estimationproject', :alias => 'EstP', :state => 'preliminary')

    @pemodule = FactoryGirl.create(:pemodule, :title => 'Bar', :alias => 'bar', :description => 'Bar module',
                                   :record_status => defined_status,
                                   :compliant_component_type=>['Toto'])

    @mp1 = ModuleProject.create(:project_id => @project.id, :pemodule_id => @pemodule.id, :position_y => 1)
    @mp2 = ModuleProject.create(:project_id => @project.id, :pemodule_id => @pemodule.id, :position_y => 2)

    @sloc_attribute = FactoryGirl.create(:sloc_attribute)
    @cost_attribute = FactoryGirl.create(:cost_attribute)

    @sloc_estimation_value = EstimationValue.create(:module_project_id => @mp1.id, :pe_attribute_id => @sloc_attribute.id, :in_out => 'input', :is_mandatory => true)
    @cost_estimation_value = EstimationValue.create(:module_project_id => @mp1.id, :in_out => 'output', :pe_attribute => @cost_attribute)
  end

  it 'should be valid' do
    @project.should be_valid
    @pemodule.should be_valid
    @mp1.should be_valid
    @mp2.should be_valid
  end

  it 'should have valid estimation data' do
    @sloc_attribute.should be_valid
    @cost_attribute.should be_valid
    @sloc_estimation_value.should be_valid
    @cost_estimation_value.should be_valid
  end


  it 'should validate 15 because 15 is greater than 10' do
    expect(@sloc_estimation_value.is_validate('15')).to be_truthy
  end

  it 'should not validate 9 because 9 is lower than 10' do
    expect(@sloc_estimation_value.is_validate('')).to be_falsey
  end

  it 'should not be valid because toto is not a integer' do
    expect(@sloc_estimation_value.is_validate('toto')).to be_falsey
  end

  it 'should not be valid because string to evaluate is wrong' do
    expect(@sloc_estimation_value.is_validate('>')).to be_falsey
  end

  it 'should not be return false because eval result is nil' do
    expect(@sloc_estimation_value.is_validate('nil')).to be_falsey
  end

  it 'should be true because no options defined' do
    expect(@cost_estimation_value.is_validate('15')).to be_truthy
  end

  it 'should return attr name' do
    @cost_estimation_value.to_s.should eql("Cost")
  end

end