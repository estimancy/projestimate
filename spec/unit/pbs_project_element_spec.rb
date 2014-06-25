require "spec_helper"

describe PbsProjectElement do

  before :each do
    @work_element_type = FactoryGirl.build(:work_element_type, :wet_folder)
    @folder = FactoryGirl.create(:pbs_folder)   # Pbs_project_element
    @folder1 = FactoryGirl.create(:pbs_folder, :name => "Folder1", :work_element_type => @work_element_type)
    @bad = FactoryGirl.create(:pbs_bad, :name => "bad_name")
  end

  it 'should be valid' do
    @folder.should be_valid
  end

  it "should be not valid without name" do
    @bad.name = ""
    @bad.should_not be_valid
  end

  it "should return PBS Project element name" do
    @folder.to_s.should eql("Folder")
  end

  it "should have a correct type" do
    expect(@folder1.name).to eql("Folder1")
  end

  it "should duplicate pbs project element" do
    @folder2 = @folder.amoeba_dup
    @folder2.copy_id = @folder.id
  end

end
