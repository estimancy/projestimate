require 'spec_helper'

describe Profile do

  before :each do
    @profile = FactoryGirl.create(:profile)
  end

  it 'should be a valid profile' do
    @profile.should be_valid
  end

  it 'should have name' do
    @profile.to_s.should include("Profile")
  end

end