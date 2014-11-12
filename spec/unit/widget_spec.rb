require "spec_helper"

describe Widget do

  before :each do
    @widget = Widget.new
  end

  it 'should be not valid' do
    @widget.should be_valid
  end

  it "should not be valid without name" do
    @widget.name = ""
    @widget.should_not be_valid
  end

  it "should be return name" do
    @widget.name = "az"
    @widget.should eql("az")
  end

end