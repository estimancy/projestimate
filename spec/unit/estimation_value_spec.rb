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

    @ksloc_attribute = FactoryGirl.create(:ksloc_attribute)
    @cost_attribute = FactoryGirl.create(:cost_attribute)

    @ksloc_estimation_value = EstimationValue.create(:module_project_id => @mp1.id, :pe_attribute_id => @ksloc_attribute.id, :in_out => 'input', :is_mandatory => true)
    @cost_estimation_value = EstimationValue.create(:module_project_id => @mp1.id, :in_out => 'output', :pe_attribute => @cost_attribute)
  end

  it 'should be valid' do
    @project.should be_valid
    @pemodule.should be_valid
    @mp1.should be_valid
    @mp2.should be_valid
  end

  it 'should have valid estimation data' do
    @ksloc_attribute.should be_valid
    @cost_attribute.should be_valid
    @ksloc_estimation_value.should be_valid
    @cost_estimation_value.should be_valid
  end


  it 'should validate 15 because 15 is greater than 10' do
    @ksloc_estimation_value.is_validate('15').should be_true
  end

  it 'should not validate 9 because 9 is lower than 10' do
    @ksloc_estimation_value.is_validate('').should be_false
  end

  it 'should not be valid because toto is not a integer' do
    @ksloc_estimation_value.is_validate('toto').should be_false
  end

  it 'should not be valid because string to evaluate is wrong' do
    @ksloc_estimation_value.is_validate('>').should be_false
  end

  it 'should not be return false because eval result is nil' do
    @ksloc_estimation_value.is_validate('nil').should be_false
  end

  it 'should be true because no options defined' do
    @cost_estimation_value.is_validate('15').should be_true
  end

  it 'should return attr name' do
    @cost_estimation_value.to_s.should eql("Cost")
  end

end