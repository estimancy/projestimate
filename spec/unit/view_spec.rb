require "spec_helper"

describe View do

  before :each do
    @view = View.new
  end

  it 'should be not valid' do
    @view.should be_valid
  end

  it "should not be valid without name" do
    @view.name = ""
    @view.should_not be_valid
  end

  it "should be return name" do
    @view.name = "az"
    @view.should eql("az")
  end

end