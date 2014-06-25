require "spec_helper"

describe EstimationValue do

  before :each do
    @project = FactoryGirl.create(:project)   #@project = Project.first
    @pemodule = Pemodule.new(:title => "Foo",
                            :alias => "foo",
                            :description => "Bar")
    @module_project = ModuleProject.new(:project_id => @project.id, :pemodule_id => @pemodule.id, :position_y => 1)
    @ksloc_attribute = PeAttribute.new(:name=>"Cost",:alias=>"cost",:description=>"Cost desc" ,:attr_type=>"Integer")
    @ksloc_attribute2 = PeAttribute.new(:name=>1,:alias=>"cost",:description=>"Cost desc" ,:attr_type=>"Integer")

    @mpa = EstimationValue.new(:pe_attribute_id => @ksloc_attribute.id,
                                      :in_out => "input",
                                      :module_project_id => @module_project.id,
                                      :custom_attribute => "user",
                                      :is_mandatory => true,
                                      :description => "Undefined")

    @mpa2 = EstimationValue.new(:pe_attribute_id => @ksloc_attribute2.id,
                                      :in_out => "input",
                                      :module_project_id => @module_project.id,
                                      :custom_attribute => "toto",
                                      :is_mandatory => true,
                                      :description => "Undefined")


    @mpa2.save
    @mpa.save
  end

  it "should return custom attribute or not " do
    expect(@mpa.custom_attribute?).to be_truthy
  end
  it "should return custom attribute or not " do
    expect(@mpa2.custom_attribute?).to be_falsey
  end
  #it "should be not valid" do
  #  @mpa2.to_s.should_not be_instance_of(String)
  #end
  #
  #it "should be valid" do
  #  @mpa.to_s.should be_an_instance_of(String)
  #end
  #
  #it "should return module project attribute name" do
  #  puts @ksloc_attribute.name
  #  puts @mpa.to_s
  #  @mpa.to_s.should eql(@ksloc_attribute.name)
  #end

  it "in_out should be equals to type" do
    @mpa.in_out.should eql(@mpa.in_out)
  end
end
