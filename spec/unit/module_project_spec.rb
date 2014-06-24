require 'spec_helper'

describe ModuleProject do

  proposed_status = FactoryGirl.build(:proposed_status)
  before :each do
    @project = FactoryGirl.create(:project, :title => 'M1project', :alias => 'M1P', :state => 'preliminary')

    @pemodule = FactoryGirl.create(:pemodule, title: 'Foo', alias: 'foo', description: 'Bar', compliant_component_type: ['Toto'])

    @mp1 = ModuleProject.create(:project_id => @project.id, :position_y => 1, :pemodule => @pemodule)
    @mp2 = ModuleProject.create(:project_id => @project.id, :position_y => 1, :pemodule => @pemodule)
    @mp3 = ModuleProject.create(:project_id => @project.id, :position_y => 3, :pemodule => @pemodule)
    @mp4 = ModuleProject.create(:project_id => @project.id, :position_y => 4, :pemodule => @pemodule)
    @mp5 = ModuleProject.create(:project_id => @project.id, :position_y => 5, :pemodule => @pemodule)
    @mp6 = ModuleProject.create(:project_id => @project.id, :position_y => 6, :pemodule => @pemodule)

    @mp7 = ModuleProject.create(:project_id => @project.id, :position_y => 7, :pemodule => @pemodule)
    @mp8 = ModuleProject.create(:project_id => @project.id, :position_y => 8, :pemodule => @pemodule)

    AssociatedModuleProject.create(:associated_module_project_id => @mp5.id, :module_project_id => @mp6.id)
    AssociatedModuleProject.create(:associated_module_project_id => @mp5.id, :module_project_id => @mp4.id)
    AssociatedModuleProject.create(:associated_module_project_id => @mp3.id, :module_project_id => @mp1.id)
    AssociatedModuleProject.create(:associated_module_project_id => @mp3.id, :module_project_id => @mp2.id)

    #AssociatedModuleProject.create(:associated_module_project_id => @mp4.id, :module_project_id => @mp5.id)
    #AssociatedModuleProject.create(:associated_module_project_id => @mp1.id, :module_project_id => @mp3.id)
    #AssociatedModuleProject.create(:associated_module_project_id => @mp2.id, :module_project_id => @mp3.id)

    AssociatedModuleProject.create(:associated_module_project_id => @mp7.id, :module_project_id => @mp8.id)
  end

  it 'should feet for bidirectional relation' do
    @mp8.previous().include?(@mp7).should be_true
    @mp8.preceding().include?(@mp7).should be_true
    @mp7.following().include?(@mp8).should be_true
    @mp7.next().include?(@mp8).should be_true
  end

  it 'should have a valid module' do
   @pemodule.should be_valid
  end

  it 'should have a valid project' do
   @project.should be_valid
  end

  it 'all pemodule should be valid' do
   @mp1.should be_valid
   @mp2.should be_valid
   @mp3.should be_valid
   @mp4.should be_valid
   @mp5.should be_valid
  end

  it 'should return a project' do
    @mp1.project.should be_a_kind_of(Project)
    @mp2.project.should be_a_kind_of(Project)
    @mp3.project.should be_a_kind_of(Project)
    @mp4.project.should be_a_kind_of(Project)
    @mp5.project.should be_a_kind_of(Project)
  end

  it 'should have precedings' do
    @mp6.preceding.should include(@mp5)
  end

  #Don't modify please: tests failed because methods next and previous are not functional'
  it 'should return next module project' do
    @mp4.next().include?(@mp5).should be_true
  end
  it 'should return previous module project' do
    @mp5.previous().include?(@mp4).should be_true
  end

  it 'should not return next module project' do
    @mp5.next().include?(@mp4).should be_false
  end
  it 'should not return previous module project' do
    @mp4.previous().include?(@mp5).should be_false
  end

  it 'should be return false if pemodule.compliant_component_type is nil' do
    @mp2.pemodule.compliant_component_type=nil
    @mp2.compatible_with('Toto').should be_false
  end

  it 'should be return pemodule.compliant_component_type include alias' do
    @mp2.compatible_with('Toto').should be_true
  end

  it 'should be return pemodule.compliant_component_type include alias' do
    @mp2.compatible_with('Tata').should be_false
  end

  it 'should a string' do
    @mp2.to_s.should be_an_instance_of(String)
  end

  it 'should return pemodule title' do
    @mp2.to_s.should include(@mp2.pemodule.title)
  end


  it 'should return previous modules or nil if first modules' do
    #@mp5.associated_module_projects << @mp6

    @mp1.previous.should be_empty
    @mp5.previous.should_not be_empty    #be_a_kind_of

    @mp1.previous.should be_empty

    @mp5.previous.size.should eql(1)
    @mp3.previous.size.should eql(2)
    @mp5.previous.first.position_y.should eql(4)
  end


  it "should be a One Activity-elements" do
    @mp1.is_All_Activity_Elements?.should be_false
  end

  it 'should be an Array' do
    @mp1.links.should be_an_instance_of(Array)
  end

  it 'should be an Array' do
    @mp1.input_attributes.should be_an_instance_of(Array)
  end

  it 'should be an Array' do
    @mp1.output_attributes.should be_an_instance_of(Array)
  end

end
