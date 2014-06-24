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